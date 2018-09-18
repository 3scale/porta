require 'test_helper'
module Payment
  class BraintreeBlueErrorsHandlerTest < ActiveSupport::TestCase
    test 'errors are present in payload' do
      result = Braintree::ErrorResult.new(
        :gateway,
        params: 'params',
        errors: {
          address: {
            errors: [
              {
                code: 81808,
                message: 'Postal code is required.',
                attribute: 'postal_code'
              },
              {
                code: 81811,
                message: 'Street address is required.',
                attribute: 'street_address'
              }
            ]
          }
        },
        verification: nil,
        transaction: nil
      )
      handler = Payment::BraintreeBlueErrorsHandler.new result

      System::ErrorReporting.expects(:report_error).never
      assert_equal ['Postal code is required.', 'Street address is required.'], handler.messages
    end

    test 'errors are absent in payload but a credit card verification failed' do
      result = Braintree::ErrorResult.new(
        :gateway,
        params: 'params',
        errors: {},
        verification: {
          status: 'verified',
          avs_error_response_code: 'I',
          avs_postal_code_response_code: 'I',
          avs_street_address_response_code: 'I',
          cvv_response_code: 'I',
          processor_response_code: '2000',
          processor_response_text: 'Do Not Honor',
          merchant_account_id: 'some_id'
        },
        transaction: nil
      )
      handler = Payment::BraintreeBlueErrorsHandler.new result

      System::ErrorReporting.expects(:report_error).with(instance_of(Payment::BraintreeBlueErrorsHandler::BraintreeResultError))
      assert_equal ['A card verification has failed. Please contact your bank.'], handler.messages
    end

    test 'bugsnag metadata in BraintreeResultError' do
      assert Payment::BraintreeBlueErrorsHandler::BraintreeResultError.include?(Bugsnag::MetaData)
      data = {
        params: 'params',
        errors: {},
        verification: {
          status: 'verified',
          avs_error_response_code: 'I',
          avs_postal_code_response_code: 'I',
          avs_street_address_response_code: 'I',
          cvv_response_code: 'I',
          processor_response_code: '2000',
          processor_response_text: 'Do Not Honor',
          merchant_account_id: 'some_id'
        },
        transaction: nil
      }
      result = Braintree::ErrorResult.new(
        :gateway,
        data
      )


      error = Payment::BraintreeBlueErrorsHandler::BraintreeResultError.new(result)
      assert_equal({ result: data.as_json }, error.bugsnag_meta_data)
    end
  end
end
