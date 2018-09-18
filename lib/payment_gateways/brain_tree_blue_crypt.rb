module PaymentGateways
  class BrainTreeBlueCrypt < PaymentGatewayCrypt
    attr_reader :gateway_client, :gateway

    def initialize(user)
      super
      @gateway_client = Braintree::Gateway.new(
        environment: (test? ? :sandbox : :production),
        merchant_id: payment_gateway_options[:merchant_id],
        public_key: payment_gateway_options[:public_key],
        private_key: payment_gateway_options[:private_key]
      )
      @gateway = @gateway_client.transparent_redirect
    end

    def confirm(request)
      gateway.confirm(request.query_string)
    rescue Braintree::BraintreeError => e
      notify_exception(e, request.query_string)
      false
    end

    def form_url
      gateway.url
    end

    def create_customer_data(options)
      customer = find_customer
      if customer
        remote_update_credit_card(customer, options)
      else
        gateway.create_customer_data(options.merge(customer: { id: buyer_reference_for_update }))
      end
    end

    def find_customer
      try_find_customer(account.credit_card_auth_code_was) || try_find_customer(buyer_reference_for_update)
    end

    # This will update the last saved credit card if it exists
    # :reek:FeatureEnvy {enabled: false}
    def remote_update_credit_card(customer, options)
      token = customer.credit_cards.first.try!(:token)
      credit_card_options = token ? { customer: { credit_card: { options: { update_existing_token: token } } } } : {}
      gateway.update_customer_data(options.merge(customer_id: customer.id).merge(credit_card_options))
    end

    # Try to find a customer that matches the customer_id
    # if found returns the provided customer result otherwise nil
    def try_find_customer(customer_id)
      return if customer_id.blank?
      gateway_client.customer.find customer_id
    rescue Braintree::NotFoundError
      nil
    end

    def buyer_reference_for_update
      auth_code = account.credit_card_auth_code_was
      auth_code.presence ||
        [buyer_reference, buyer_reference_for_update_counter(auth_code)].compact.join('-')
    end

    def update_user(result)
      if customer_id_mismatch?(result)
        data =  {
          gateway: :braintree,
          actual: result.customer.id,
          expected: buyer_reference_for_update,
          account_id: account.id,
          user_id: user.id,
          email: user.email
        }
        notify_exception CustomerIdMismatchError.new(data), data
        false
      else
        self.account_billing_address = result
        self.account_credit_card_details = result
        account.save!
      end
    end

    def errors(result)
      Payment::BraintreeBlueErrorsHandler.new(result).messages
    rescue ::Payment::BraintreeBlueErrorsHandler::NotFailedResultError
      []
    end

    protected

    # After many hacks we finally have a real update but then we have to deal with backward compatibility
    # This is to know if the customer sent back by Braintree matches the one we ask them to set
    # :reek:FeatureEnvy {enabled: false}
    def customer_id_mismatch?(result)
      customer_id = result.customer.id
      return true if customer_id.blank?
      # This check: result.customer.id =~ /#{buyer_reference}/ is for backward compatibility
      return false if customer_id.to_s == account.credit_card_auth_code.to_s || customer_id =~ /#{buyer_reference}/
      true
    end

    def account_credit_card_details=(result)
      credit_card                          = result.customer.credit_cards.first #first cc is the last inserted
      # FIXME: Strange it is stated above the first is the last inserted
      account.credit_card_partial_number   = result.customer.credit_cards.last.last_4
      account.credit_card_expires_on_year  = credit_card.expiration_year
      account.credit_card_expires_on_month = credit_card.expiration_month
      account.credit_card_auth_code        = result.customer.id
    end

    # rubocop:disable Metrics/AbcSize
    def account_billing_address=(result)
      account.billing_address_first_name   = result.customer.first_name
      account.billing_address_last_name    = result.customer.last_name
      account.billing_address_phone        = result.customer.phone
      address                              = result.customer.addresses.last  #last address is the last inserted
      account.billing_address_name         = address.company
      account.billing_address_address1     = address.street_address
      account.billing_address_city         = address.locality
      account.billing_address_country      = address.country_name
      account.billing_address_state        = address.region
      account.billing_address_zip          = address.postal_code
    end

    def buyer_reference_for_update_counter(auth_code)
      _3scale, _provider_id, _buyer_id, index = auth_code.to_s.split('-')
      index = index.to_i
      index.zero? ? 1 : index
    end
  end
end
