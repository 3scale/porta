module Payment
  class Adyen12ErrorsHandler < AbstractErrorsHandler
    class Adyen12ResultError < StandardError
      include Bugsnag::MetaData

      def initialize(result)
        self.bugsnag_meta_data = {
          result: result.as_json
        }
        super 'Adyen12 call failed but refusal reason is not handled'
      end
    end

    ERRORS_FILE = Rails.root.join('config/adyen_errors.yml').freeze
    ERROR_MESSAGES = YAML.load_file(ERRORS_FILE).freeze

    def messages
      @messages ||= collect_messages.freeze
    end

    private

    def collect_messages
      # API request rejected
      # See https://docs.adyen.com/developers/api-manual#errorresponsefields
      if response.params.key?('errorCode')
        [response.message]
      else
        collect_messages_from_refusal
      end
    end

    # API request succeeded but authorization failed
    # See https://docs.adyen.com/developers/api-manual#authorisationrefusalreasons
    def collect_messages_from_refusal
      reason = response.params['refusalReason']
      if ERROR_MESSAGES[reason]
        [ERROR_MESSAGES[reason]]
      else
        notify_refusal_reason_not_handled!
        []
      end
    end

    def notify_refusal_reason_not_handled!
      error = Adyen12ResultError.new(response)
      System::ErrorReporting.report_error(error)
      nil
    end
  end
end
