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
        return (account.scheduled_for_deletion? ? head(:not_found) : nil) if account.provider? && authenticated_request.zync?

        head(:forbidden)
      end
    end
  end
end
