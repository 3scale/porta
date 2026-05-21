# frozen_string_literal: true

module ApiAuthentication
  module ByZyncToken
    extend ActiveSupport::Concern

    included do
      prepend_before_action :authenticate_zync_request, only: %i[show find]
    end

    private

    def current_user
      if @zync_authenticated
        @current_user ||= User.current = (domain_account.find_impersonation_admin || domain_account.first_admin!)
      else
        super
      end
    end

    def authenticate_zync_request
      return unless zync_request?
      return if domain_account.master?

      @zync_authenticated = true
    end

    def zync_request?
      AuthenticatedSystem::Request.new(request).zync?
    end

    # Force read-only DB transaction for Zync requests.
    # ByAccessToken's version calls PermissionEnforcer.enforce(authenticated_token) — with
    # no access token, authenticated_token is nil, level becomes nil, and
    # requires_transaction? returns nil, skipping enforcement entirely.
    def enforce_access_token_permission(&block)
      if @zync_authenticated
        ApiAuthentication::ByAccessToken::PermissionEnforcer.enforce(OpenStruct.new(permission: 'ro'), &block)
      else
        super
      end
    end
  end
end
