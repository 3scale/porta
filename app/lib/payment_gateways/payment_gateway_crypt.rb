# frozen_string_literal: true

module PaymentGateways
  class CreditCardException < RuntimeError; end
  class PaymentGatewayDown < RuntimeError; end
  class IncorrectKeys < CreditCardException; end

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

    def update_payment_detail(card, payment_method_id, payment_method)
      payment_detail.credit_card_expires_on     = Date.new(card.exp_year, card.exp_month)
      payment_detail.credit_card_partial_number = card.last4
      payment_detail.credit_card_auth_code      = payment_method.customer
      payment_detail.payment_method_id          = payment_method_id
      payment_detail.save
    end

    def handle_stripe_error(stripe_error)
      report_error("Failed to update billing address on Stripe: #{stripe_error.message}")
      false
    end

    private

    def log_gateway_action_explicit(gateway, action)
      Rails.logger.info "----------"
      Rails.logger.info "~>[Payment gateway][#{gateway&.display_name}] #{action}"
      Rails.logger.info "----------"
    end

    # TODO: remove, refactor
    def log_gateway_action(action)
      log_gateway_action_explicit(provider.payment_gateway, action)
    end

  end
end
