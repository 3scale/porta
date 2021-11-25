# frozen_string_literal: true

class Partners::SessionsController < Partners::BaseController

  skip_before_action :authenticate!

  def openid
    authenticate_with_open_id(params.require(:openid_url)) do |result, identity_url, registration|
      if result.successful?
        @user = User.find_by!(open_id: identity_url)
        @account = @user.account
        sso_token = SSOToken.new user_id: @user.id
        sso_token.protocol = 'http' unless request.ssl?
        sso_token.account = @account
        sso_url = sso_token.sso_url!(@account.external_admin_domain)
        return_to_param = params.require(:return_to)
        sso_url << "&return_to=#{return_to_param}" if return_to_param.present?
        redirect_to sso_url
      end
    end
  end
end
