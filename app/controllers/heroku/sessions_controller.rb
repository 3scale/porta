class Heroku::SessionsController < Heroku::BaseController
  include AuthenticatedSystem
  include Heroku::ControllerMethods

  def create
    logout_keeping_session!
    pre_token = params[:id] + ':' + Heroku.sso_salt + ':' + params[:timestamp]
    token = Digest::SHA1.hexdigest(pre_token).to_s
    head 403 and return false if token != params[:token]
    head 403 and return false if params[:timestamp].to_i < (Time.now - 2*60).to_i

    return false unless find_user_and_account

    session[:heroku_sso] = true
    cookies['heroku-nav-data'] = { value: params['nav-data'], :path => '/'}

    sso_token = SSOToken.new user_id: @user.id
    sso_token.protocol = 'http' unless request.ssl?
    sso_token.account = @account
    sso_url = sso_token.sso_url!(target_host(@account))
    sso_url << "&return_to=#{params[:return_to]}" if params[:return_to].present?
    redirect_to sso_url
  end
end
