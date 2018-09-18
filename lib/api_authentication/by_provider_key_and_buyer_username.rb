module ApiAuthentication
  # Include this module into a controller if you want to enable authentication
  # with provider_key and buyer's username.
  module ByProviderKeyAndBuyerUsername
    private

    def current_user
      super || if params[:provider_key] != site_account.api_key
                 nil
               else
                 site_account.buyer_users.find_by_username(params[:username])
               end
    end

    def handle_access_denied(e)
      # exception created by access_control.rb does not have backtrace (it used to be nil)
      msg = if e.is_a?(CanCan::AccessDenied) && e.backtrace
              e.message
            else
              'username is invalid'
            end

      render_error msg, :status => :forbidden
    end
  end
end
