module ActiveMerchantTestHelpers
  protected

  def build_active_merchant_response(success, json_string, options={})
    json = JSON.parse(json_string)
    ActiveMerchant::Billing::Response.new(success, success ? 'success' : 'failed', json, options)
  end

  module BraintreeBlue
    def successful_result(user = nil)
      json = {
      customer: {
        id: user ? PaymentGateways::BrainTreeBlueCrypt.new(user).buyer_reference_for_update : '1234',
        first_name: 'John',
        last_name: 'Doe',
        phone: '+1234567890',
        credit_cards: [
          {
            expiration_month: '01',
            expiration_year: '2019',
            last_4: '7654'
          }
        ],
        addresses: [
          {
            company: '3scale',
            street_address: 'Carrer de Napols, 187',
            locality: 'Barcelona',
            country_name: 'Spain',
            region: 'Barcelona',
            postal_code: '08013'
          }
        ]
      }
      }.to_json

      result = JSON.parse(json, object_class: OpenStruct)
      result.stubs(success?: true)
      result
    end

    # See https://developers.braintreepayments.com/reference/general/validation-errors/all/ruby#credit-card
    def failed_result
      json = {
          errors: [
              {
                  message: 'Credit card number must be 12-19 digits.'
              },
              {
                  message: 'CVV is required.'
              }
          ]
      }.to_json
      result = JSON.parse(json, object_class: OpenStruct)
      result.stubs(success?: false)
      result
    end
  end
end
