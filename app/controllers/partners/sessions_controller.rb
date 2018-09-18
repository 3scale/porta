class Partners::SessionsController < Partners::BaseController

  skip_before_action :authenticate!

  def openid
    authenticate_with_open_id(params[:openid_url]) do |result, identity_url, registration|
      if result.successful?
        @user = User.find_by!(open_id: identity_url)
        @account = @user.account
        sso_token = SSOToken.new user_id: @user.id
        sso_token.protocol = 'http' unless request.ssl?
        sso_token.account = @account
        sso_url = sso_token.sso_url!(target_host(@account))
        sso_url << "&return_to=#{params[:return_to]}" if params[:return_to].present?
        redirect_to sso_url
      end
    end
  end
end
