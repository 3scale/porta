require 'test_helper'

module Payment
  class Adyen12ErrorsHandlerTest < ActiveSupport::TestCase
    test 'error from authorization refusal is handled' do
      params = {
        'refusalReason' => 'Handled Refusal Reason',
        'resultCode' => 'Declined'
      }
      response = ActiveMerchant::Billing::Response.new(false, 'authorization failed', params)
      handler = Adyen12ErrorsHandler.new(response)

      Adyen12ErrorsHandler::ERROR_MESSAGES = { 'Handled Refusal Reason' => 'This is for test' }
      System::ErrorReporting.expects(:report_error).never
      assert_equal handler.messages.first, 'This is for test'
    end

    test 'error from authorization refusal is not handled' do
      params = {
        'refusalReason' => 'Unhandled Refusal Reason',
        'resultCode' => 'Declined'
      }

      response = ActiveMerchant::Billing::Response.new(false, 'authorization failed', params)
      handler = Adyen12ErrorsHandler.new(response)

      System::ErrorReporting.expects(:report_error).with(instance_of(Payment::Adyen12ErrorsHandler::Adyen12ResultError))
      assert_nil handler.messages.first
    end

    test 'error comes from rejection' do
      params = {
        'errorType' => 'security',
        'errorCode' => '901',
        'message' => 'Invalid Merchant Account',
        'status' => '403'
      }
      response = ActiveMerchant::Billing::Response.new(false, 'Invalid Merchant Account', params)
      handler = Adyen12ErrorsHandler.new(response)

      System::ErrorReporting.expects(:report_error).never
      assert_equal handler.messages.first, 'Invalid Merchant Account'
    end

    test 'Adyen12ResultError' do
      params = {
        'refusalReason' => 'Unhandled Refusal Reason',
        'resultCode' => 'Declined'
      }

      response = ActiveMerchant::Billing::Response.new(false, 'authorization failed', params)
      error = Payment::Adyen12ErrorsHandler::Adyen12ResultError.new(response)

      assert_equal({ result: response.as_json }, error.bugsnag_meta_data)
    end
  end
end
