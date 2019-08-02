# frozen_string_literal: true

module PaymentGateways
  class Adyen12Crypt < PaymentGatewayCrypt

    CARD_DATA_ATTRIBUTES = %w[expiryMonth expiryYear number recurringDetailReference].freeze
    private_constant :CARD_DATA_ATTRIBUTES

    attr_reader :gateway_client, :authorize_response

    def initialize(user)
      super
      @gateway_client = provider.payment_gateway
    end

    # This will use ActiveMerchant::Billing::Gateway::Adyen12
    #
    # Stores a recurring contract in Adyen with the <tt>encrypted_card</tt> details
    #
    # * options may have:
    #   :ip the IP address of the current_user
    #   :recurring see https://docs.adyen.com/developers/recurring-manual#creatingarecurringcontract
    #
    # Returns a ActiveMerchant::Billing::Response
    def authorize_recurring_and_store_card_details(encrypted_card, options = {})
      @authorize_response = authorize_with_encrypted_card(encrypted_card, options)
      @authorize_response.success? && store_credit_card_details
    end

    def authorize_with_encrypted_card(encrypted_card, options = {})
      shopper_options = {
        shopperEmail: user.email,
        shopperReference: buyer_reference,
        shopperIP: options[:ip],
        recurring: 'RECURRING',
        reference: recurring_authorization_reference
      }
      gateway_client.authorize_recurring(0, encrypted_card, shopper_options)
    end

    def store_credit_card_details
      card_details = if authorize_response
                       card_alias = authorize_response.params.dig('additionalData', 'alias')
                       retrieve_card_details_with_alias(card_alias)
                     else
                       retrieve_card_details
                     end

      return false unless card_details.present?

      account.payment_detail.update_attributes(payment_detail_attributes(card_details))
    end

    def retrieve_card_details(&block)
      recurring_details = fetch_recurring_details

      return {} if recurring_details.empty?

      recurring_details.keep_if(&block) if block_given?
      slice_card_details(recurring_details.last)
    end

    def retrieve_card_details_with_alias(card_alias)
      return retrieve_card_details unless card_alias
      retrieve_card_details { |detail| detail.fetch('alias') == card_alias }
    end

    private

    def fetch_recurring_details
      response = gateway_client.list_recurring_details(buyer_reference, {recurring: 'RECURRING'})

      return [] unless response.success?

      recurring_details = response.params.fetch('details').map { |detail| detail.fetch('RecurringDetail') }
      recurring_details.sort_by! { |recurring_detail| recurring_detail['creationDate'] }
    end

    def slice_card_details(recurring_detail)
      recurring_detail['card'].slice(*CARD_DATA_ATTRIBUTES)
    end

    def payment_detail_attributes(card_details)
      {
        credit_card_partial_number: card_details['number'],
        credit_card_expires_on: Month.new(card_details['expiryYear'], card_details['expiryMonth']).first,
        buyer_reference: buyer_reference,
        payment_service_reference: card_details['recurringDetailReference']
      }
    end
  end
end
