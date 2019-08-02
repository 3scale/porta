module PaymentGateways
  class AuthorizeNetCimCrypt < PaymentGatewayCrypt

    def authorize_api_url
      ::ActiveMerchant::Billing::AuthorizeNetCimGateway.public_send(test? ? :test_url : :live_url)
    end

    def form_url
      @form_url ||= "https://#{test? ? 'test' : 'secure'}.authorize.net/profile".freeze
    end

    def create_profile
      log_gateway_action("Creating Profile")

      response = create_remote_profile
      account.credit_card_auth_code = response.params['customer_profile_id']
      account.save!
      log_gateway_action("Creating Profile ok")
    end

    def action_form_url
      action = account.credit_card_stored? ? "/editPayment" : "/addPayment"
      form_url + action
    end

    def payment_profile
      auth_response = provider.payment_gateway.cim_gateway
        .get_customer_profile(:customer_profile_id => account.credit_card_auth_code)
      return unless has_credit_card?(auth_response)
      auth_response.params['profile']['payment_profiles']['customer_payment_profile_id']
    end

    def has_credit_card?(auth_response)
      auth_response.success? &&
        auth_response.params['profile'].key?('payment_profiles') &&
        auth_response.params['profile']['payment_profiles'].key?('payment') &&
        auth_response.params['profile']['payment_profiles']['payment'].key?('credit_card')
    end

    def get_token(args)
      getHostedProfilePageRequest = <<-EOR
<?xml version="1.0" encoding="utf-8"?>
    <getHostedProfilePageRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
    <merchantAuthentication>
    <name>#{args[:login]}</name>
    <transactionKey>#{args[:trans_key]}</transactionKey>
    </merchantAuthentication>
    <customerProfileId>#{args[:profile_id]}</customerProfileId>
    <hostedProfileSettings>
    <setting>
    <settingName>hostedProfileReturnUrl</settingName>
    <settingValue>#{args[:ok_url]}</settingValue>
    </setting>
    <setting>
    <settingName>hostedProfileReturnUrlText</settingName>
    <settingValue>Continue to settings</settingValue>
    </setting>
    <setting>
    <settingName>hostedProfilePageBorderVisible</settingName>
    <settingValue>true</settingValue>
    </setting>
    </hostedProfileSettings>
  </getHostedProfilePageRequest>
EOR

      begin
        log_gateway_action("Getting token for user #{user.id}")
        crypted_request = RestClient.post authorize_api_url, getHostedProfilePageRequest,
                                          :content_type => "text/xml"

        xml_reply = Nokogiri::XML::Document.parse(crypted_request)
        if xml_reply.xpath("//api:resultCode",
                           'api' => 'AnetApi/xml/v1/schema/AnetApiSchema.xsd').text == 'Ok'
          return xml_reply.xpath("//api:token", 'api' => 'AnetApi/xml/v1/schema/AnetApiSchema.xsd').text
        else
          notify_exception(IncorrectKeys.new(xml_reply))
          code=xml_reply.xpath("//api:code", 'api' => 'AnetApi/xml/v1/schema/AnetApiSchema.xsd').text
          raise IncorrectKeys.new("code:#{code}.")
        end
        log_gateway_action("user #{user.id} token aquired")
      rescue SocketError => e
        notify_exception(e)
        raise PaymentGatewayDown.new("Payment gateway offline. Try again in few minutes")
      end

    end

    def update_user(auth_response)
      return :error unless auth_response.params['messages']['result_code'] == 'Ok'

      log_gateway_action("updating user #{user}")
      payment_profiles = auth_response.params['profile']['payment_profiles']
      if payment_profiles && payment_profiles['bill_to']
        bill_info = payment_profiles['bill_to']
        account.billing_address_name     = bill_info['company']
        account.billing_address_address1 = bill_info['address']
        account.billing_address_city     = bill_info['city']
        account.billing_address_country  = bill_info['country']
        account.billing_address_state    = bill_info['state']
        account.billing_address_zip      = bill_info['zip']
        account.billing_address_phone    = bill_info['phone_number']
      end

      account.credit_card_partial_number =
        auth_response.params['profile']['payment_profiles']['payment']['credit_card']['card_number'][-4..-1]
      account.credit_card_authorize_net_payment_profile_token =
        auth_response.params['profile']['payment_profiles']['customer_payment_profile_id']
      account.credit_card_expires_on = nil #We can't store expiration date as Authorize.net doesn't retrieve it
      account.save!
    end

    # FIXME: delete_user_profile has nothing to do in this class
    # Reusing Account#delete_cc_details
    def delete_user_profile
      account.delete_cc_details
      account.save!
    end

    private

    def create_remote_profile
      response = provider.payment_gateway.cim_gateway
        .create_customer_profile(profile: { email: user.email, description: buyer_reference })

      # this is a nice trick, where we raise IncorectKeys whatever the response was
      raise IncorrectKeys.new(response) unless response.params['messages']['result_code'] == 'Ok'
      response
    end
  end
end
