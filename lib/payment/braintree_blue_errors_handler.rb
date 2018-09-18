module Payment
  class BraintreeBlueErrorsHandler < AbstractErrorsHandler
    class BraintreeResultError < StandardError
      include Bugsnag::MetaData

      def initialize(result)
        data = result.data
        self.bugsnag_meta_data = {
          # Intentionally using double as_json
          # See: https://github.com/3scale/system/pull/7080#discussion_r70658162
          result: data.as_json
        }
        super 'Braintree call failed but has no errors in payload'
      end
    end

    CREDIT_CARD_VERIFICATION_MESSAGE = 'A card verification has failed. Please contact your bank.'.freeze

    def messages
      @messages ||= collect_messages.freeze
    end

    private

    def collect_messages
      notify_no_errors_given!
      messages = @result.errors.map(&:message)
      messages << CREDIT_CARD_VERIFICATION_MESSAGE if @result.credit_card_verification
      messages.compact!
      messages
    end

    # This will notify that some errors are not sent by Braintree
    def notify_no_errors_given!
      return if @result.errors.any?
      error = BraintreeResultError.new @result
      System::ErrorReporting.report_error(error)
    end
  end
end
