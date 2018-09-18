module ApiAuthentication
  module SuspendedAccount
    extend ActiveSupport::Concern

    included do
      before_action :forbid_suspended_account_api_access
    end

    protected

    def forbid_suspended_account_api_access
      if (account = current_account)
        head(:forbidden) unless account.approved?
      end
    end
  end
end
