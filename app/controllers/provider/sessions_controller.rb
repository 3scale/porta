# frozen_string_literal: true
class Provider::SessionsController < FrontendController

  layout 'provider/login'
  skip_before_action :login_required

  before_action :ensure_provider_domain
  before_action :find_provider
  before_action :instantiate_sessions_presenter, only: [:new, :create]

  def new
    redirect_to provider_admin_dashboard_url if logged_in?
    @session = Session.new
    @authentication_providers = published_authentication_providers
  end

  def create
    session_return_to
    logout_keeping_session!

    @user, strategy = authenticate_user

    if @user
      self.current_user = @user
      create_user_session!(strategy.authentication_provider_id)
      flash[:notice] = 'Signed in successfully'
      redirect_back_or_default provider_admin_path
    else
      @session = Session.new
      flash.now[:error] = strategy.error_message
      @authentication_providers = published_authentication_providers
      render :action => :new
    end
  end

  def bounce
    auth = domain_account.self_authentication_providers.find_by!(system_name: params.require(:system_name))
    redirect_to ProviderOauthFlowPresenter.new(auth, request, request.host).authorize_url
  end

  def destroy
    user = current_user
    logout_killing_session!
    destroy_user_session!
    if @provider.partner? && (logout_url = @provider.partner.logout_url)
      redirect_to logout_url + {user_id: user.id, provider_id: @provider.id}.to_query
    else
      redirect_to new_provider_sessions_path, notice: "You have been logged out."
    end
  end

  private

  def published_authentication_providers
    return [] unless @provider.provider_can_use?(:provider_sso)

    @provider.self_authentication_providers.published.map do |auth|
      ProviderOauthFlowPresenter.new(auth, request, request.host)
    end
  end

  def find_provider
    @provider ||= site_account_request.find_provider
  end

  def redirect_if_logged_in
    if logged_in? && current_account.provider?
      redirect_to provider_admin_dashboard_path
    end
  end

  def authenticate_user
    strategy = Authentication::Strategy.build_provider(@provider)

    params = if domain_account.settings.enforce_sso?
               sso_params
             else
               request.post? ? auth_params : sso_params
    end

    user = strategy.authenticate(params)

    [user, strategy]
  end

  def auth_params
    params.slice(:username, :password)
  end

  def sso_params
    params.permit(:token, :expires_at, :redirect_url, :system_name, :code).merge(request: request)
  end

  def session_return_to
    if params[:return_to]
      return_to = safe_return_to(params[:return_to])
      session[:return_to] = return_to if return_to.present?
    end
  end

  def instantiate_sessions_presenter
    @presenter = Provider::SessionsPresenter.new(domain_account)
  end
end
