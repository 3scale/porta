# frozen_string_literal: true

module ApiAuthentication
  module ByAccessToken
    extend ActiveSupport::Concern

    def current_user
      @current_user ||= User.current = authenticated_token&.owner
    end

    included do
      include ApiAuthentication::HttpAuthentication

      class_attribute :_access_token_scopes, instance_accessor: false
      self._access_token_scopes = []

      before_action :verify_access_token_scopes
      around_action :enforce_access_token_permission
      rescue_from ApiAuthentication::Error,
                  with: :show_access_key_permission_error
    end

    protected

    module ClassMethods
      def authenticate_access_token(status: 401, **options)
        define_method :authenticate! do
          render status: status, **options unless logged_in?
        end
      end

      def access_token_scopes=(*scopes)
        flattened_scopes = scopes.flatten
        validate_scopes!(flattened_scopes)
        self._access_token_scopes = flattened_scopes
      end

      def access_token_scopes
        _access_token_scopes
      end

      def validate_scopes!(scopes)
        available_scopes = AccessToken::SCOPES.values
        invalid_scopes   = scopes.map(&:to_s) - available_scopes

        raise(ScopeError, "scopes #{invalid_scopes} do not exist") if invalid_scopes.any?
      end
    end

    def access_token_scopes
      self.class.access_token_scopes
    end

    def allowed_scopes
      access_token_scopes.map(&:to_s) & user_allowed_scopes
    end

    def show_access_key_permission_error
      self.response_body = nil # prevent double render errors
      render_error "Your access token does not have the correct permissions", status: 403
    end

    def authenticated_token
      return @authenticated_token if instance_variable_defined?(:@authenticated_token)

      given_token = access_token

      return if given_token.blank?

      token = domain_account.access_tokens.find_from_value(given_token)

      return if token.blank? || token.expired?

      @authenticated_token = token
    end

    def enforce_access_token_permission(&block)
      PermissionEnforcer.enforce(authenticated_token, &block)
    end

    def verify_access_token_scopes
      return true unless authenticated_token

      raise PermissionError if !authenticated_token || allowed_scopes.blank?
      raise ScopeError if (allowed_scopes & authenticated_token.scopes).blank?

      true
    end

    def verify_write_permission
      return true unless authenticated_token
      raise PermissionError unless authenticated_token.try(:permission) == PermissionEnforcer::READ_WRITE
    end

    private

    def access_token
      @access_token ||= params.fetch(:access_token, &method(:http_authentication))
    end

    def user_allowed_scopes
      @user_allowed_scopes ||= current_user.allowed_access_token_scopes.values
    end
  end
end
