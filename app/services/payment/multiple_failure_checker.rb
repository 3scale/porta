# frozen_string_literal: true

module Payment
  class MultipleFailureChecker
    def initialize(account, payment_status, user_session = UserSession.new)
      @account            = account
      @payment_successful = payment_status
      @user_session       = user_session
    end

    def call
      return if payment_successful

      limiter = ActionLimiter.new(account)
      limiter.perform 'invalid_payment'
    rescue ActionLimiter::ActionLimitsExceededError
      account.suspend!
      user_session.revoke!
      Rails.logger.info "spam_protection_service: account_suspended id: #{account.id}"
    end

    private

    attr_reader :account, :gateway_setting, :payment_successful, :user_session
  end
end
