# frozen_string_literal: true

module ApiAuthentication
  module ByToken
    extend ActiveSupport::Concern

    class ByTokenError < StandardError; end
    class UserNotFoundError < ByTokenError; end
    class InvalidSsoTokenError < ByTokenError; end

    def current_user
      @current_user ||= sso_token ? authenticated_user_by_sso_token : (defined?(super) && super)
    end

    included do
      before_action :verify_sso_token
      rescue_from ApiAuthentication::ByToken::ByTokenError, with: :show_sso_token_error
    end

    private

    def token_strategy
      Authentication::Strategy::Token.new(domain_account, true)
    end

    def authenticated_user_by_sso_token
      token_strategy.authenticate_by_token(sso_token) or raise UserNotFoundError
    end

    def verify_sso_token
      token = params.fetch(:token) { return }
      raise InvalidSsoTokenError if token.blank?
      token
    end
    alias verified_sso_token verify_sso_token

    def show_sso_token_error
      render_error 'Your token is invalid', status: 403
    end

    def sso_token
      @sso_token ||= verified_sso_token
    end
  end
end
