# frozen_string_literal: true

module ApiAuthentication
  module SuspendedAccount
    extend ActiveSupport::Concern

    included do
      before_action :forbid_suspended_account_api_access
    end

    protected

    def forbid_suspended_account_api_access
      if (account = current_account)
        return if account.approved?
        return if account.provider? && account.scheduled_for_deletion? && zync_fetch_request?

        head(:forbidden)
      end
    end

    private

    # We allow zync to fetch data for accounts scheduled for deletion.
    # The exception applies only when:
    #
    # 1. It's a read-only request (GET)
    # 2. It comes from Zync (Includes a valid zync header)
    # 3. It's authenticated via an OIDC synchronization token.
    def zync_fetch_request?
      request.get? && authenticated_request.zync? && authenticated_token&.name == AccessToken::OIDC_SYNC_TOKEN
    end
  end
end
