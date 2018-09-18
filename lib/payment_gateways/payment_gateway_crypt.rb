module PaymentGateways
  class CreditCardException < RuntimeError ; end
  class PaymentGatewayDown < RuntimeError ; end
  class IncorrectKeys < CreditCardException ; end

  class CustomerIdMismatchError < StandardError
    include Bugsnag::MetaData
    def initialize(gateway:, actual:, expected:, **params)
      super("Customer ID mismatch for #{gateway}. Expected `#{actual}` to be `#{expected}`")

      self.bugsnag_meta_data = {
        params: params,
        gateway: gateway,
        mismatch: { expected: expected, actual: actual }
      }
    end
  end

  class PaymentGatewayCrypt
    include PaymentGateways::BuyerReferences

    attr_reader :account, :payment_gateway_options, :provider, :user

    def initialize(user)
      @user = user
      @account = @user.account
      @provider = @account.provider_account
      @payment_gateway_options = @provider.payment_gateway_options
    end

    # WARNING this method must not be overriden by subclasses
    def test?
      ActiveMerchant::Billing::Base.test?
    end

    def notify_exception(e, query_string = nil)
      msg = "[Payment gateway] error for user `#{user.id}' of provider `#{provider.id}': #{e.inspect}, query_sting: #{query_string}"
      System::ErrorReporting.report_error(e, query_string: query_string)
      Rails.logger.error(msg)
    end

    private

    def log_gateway_action_explicit(gateway, action)
      Rails.logger.info "----------"
      Rails.logger.info "~>[Payment gateway][#{gateway.try!(:display_name)}] #{action}"
      Rails.logger.info "----------"
    end

    # TODO: remove, refactor
    def log_gateway_action(action)
      log_gateway_action_explicit(provider.payment_gateway, action)
    end

  end
end
