# frozen_string_literal: true

module Backend
  ERRORS = {
    'user.invalid_key' => 'user_key is invalid',
    'user.inactive_contract' => 'contract is not active',
    'user.exceeded_limits' => 'usage limits are exceeded',
    'user.exceeded_credit' => 'credit is exceeded',
    'provider.invalid_key' => 'provider authentication key is invalid',
    'provider.invalid_metric' => 'metric does not exist',
    'provider.invalid_service' => 'service does not exist',
    'provider.invalid_usage_value' => 'usage value is invalid',
    'provider.invalid_transaction_id' => 'transaction does not exist'
  }.freeze

  class Error < StandardError
    attr_reader :code

    def initialize(code, message = nil)
      super(message || ERRORS[code])
      @code = code
    end

    def to_xml(options = {})
      xml = Builder::XmlMarkup.new
      xml.instruct! unless options[:skip_instruct]
      xml.error(message, :id => code)
      xml.target!
    end
  end

  class ServiceNotFound < Error
    def initialize
      super('provider.invalid_service')
    end
  end

  class UserKeyInvalid < Error
    def initialize
      super('user.invalid_key')
    end
  end

  class ContractNotActive < Error
    def initialize
      super('user.inactive_contract')
    end
  end

  class LimitsExceeded < Error
    def initialize(message = nil)
      super('user.exceeded_limits', message)
    end
  end

  class CreditExceeded < Error
    def initialize
      super('user.exceeded_credit')
    end
  end

  class ProviderKeyInvalid < Error
    def initialize
      super('provider.invalid_key')
    end
  end

  class MetricNotFound < Error
    def initialize
      super('provider.invalid_metric')
    end
  end

  class UsageValueInvalid < Error
    def initialize
      super('provider.invalid_usage_value')
    end
  end

  class TransactionNotFound < Error
    def initialize
      super('provider.invalid_transaction_id')
    end
  end

  # This error can be raised in batch-processed transaction, where multiple transaction can
  # be invalid, but all have to be reported at the same time.
  class MultipleErrors < StandardError
    attr_reader :codes

    def initialize(codes)
      @codes = codes
    end

    def message
      codes.map { |index, code| "#{index}: #{ERRORS[code]}" }.join("\n")
    end

    def to_xml(options = {})
      xml = Builder::XmlMarkup.new
      xml.instruct! unless options[:skip_instruct]
      xml.errors do
        codes.each do |index, code|
          xml.error ERRORS[code], :id => code, :index => index
        end
      end
      xml.target!
    end
  end
end
