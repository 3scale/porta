module ActiveMerchantTestHelpers
  protected

  def build_active_merchant_response(success, json_string, options={})
    json = JSON.parse(json_string)
    ActiveMerchant::Billing::Response.new(success, success ? 'success' : 'failed', json, options)
  end

  module AuthorizeNet

    def failed_get_customer_profile_response
      json_string = <<-JSON
      {
        "messages": {
          "result_code": "Error",
          "message": {
            "test": "Failed to get profile"
          }
        }
      }
      JSON
      build_active_merchant_response(false, json_string)
    end

    def successful_get_customer_profile_response
      json_string = <<-JSON
      {
        "messages": {
          "result_code": "Ok"
        },
        "profile": {
          "payment_profiles": {
            "customer_payment_profile_id": 12345,
            "payment": {
              "credit_card": {
                "card_number": "4444",
                "expiration_date": "XXXX"
              }
            },
            "bill_to": {
              "company": "3scale",
              "address": "Carrer Napols",
              "city": "Barcelona",
              "country": "Spain",
              "state": "Barcelona",
              "zip": "08013",
              "phone_number": "+34123456789"
            }
          }
        }
      }
      JSON
      build_active_merchant_response(true, json_string)
    end

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
