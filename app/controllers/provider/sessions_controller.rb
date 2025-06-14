# frozen_string_literal: true
class Provider::SessionsController < FrontendController
  include ThreeScale::BotProtection::Controller

  layout 'provider/login'
  skip_before_action :login_required

  before_action :ensure_provider_domain
  before_action :find_provider
  before_action :instantiate_sessions_presenter, only: [:new, :create]
  before_action :redirect_if_logged_in, only: %i[new]

  def new
    @session = Session.new
    @authentication_providers = published_authentication_providers
    @bot_protection_enabled = bot_protection_enabled?
  end

  def create
    session_return_to
    logout_keeping_session!

    @user, strategy = authenticate_user

    if @user
      self.current_user = @user
      flash[:first_login] = true if current_user.user_sessions.empty?
      create_user_session!(strategy&.authentication_provider_id)

      redirect_back_or_default provider_admin_path, success: t('.success')
    else
      new
      flash.now[:danger] ||= strategy&.error_message
      attempted_cred = auth_params.fetch(:username, 'SSO')
      AuditLogService.call("Login attempt failed from #{request.remote_ip}: #{domain_account.external_admin_domain} - #{attempted_cred}. ERROR: #{strategy&.error_message}")
      render :action => :new
    end
  end

  def bounce
    auth = domain_account.self_authentication_providers.find_by!(system_name: params.require(:system_name))
    redirect_to ProviderOAuthFlowPresenter.new(auth, request, request.host).authorize_url
  end

  def destroy
    user = current_user
    logout_killing_session!
    destroy_user_session!

    if @provider.partner? && (logout_url = @provider.partner.logout_url)
      redirect_to logout_url + {user_id: user.id, provider_id: @provider.id}.to_query
    else
      redirect_to new_provider_sessions_path, info: t('.logged_out')
    end
  end

  private

  def published_authentication_providers
    return [] unless @provider.provider_can_use?(:provider_sso)

    @provider.self_authentication_providers.published.map do |auth|
      ProviderOAuthFlowPresenter.new(auth, request, request.host)
    end
  end

  def find_provider
    @provider ||= site_account_request.find_provider
  end

  def redirect_if_logged_in
    redirect_to provider_admin_dashboard_path if logged_in?
  end

  def authenticate_user
    strategy = Authentication::Strategy::InferService.call(auth_params, @provider, admin_domain: true).result

    return if strategy.bot_protected? && !bot_check

    user = strategy.authenticate(auth_params)
    [user, strategy]
  end

  def auth_params
    params.permit(*%i[username password ticket token expires_at redirect_url system_name code]).merge(request:)
  end

  def session_return_to
    return_to_params = params.permit(:return_to)[:return_to]

    return unless return_to_params

    return_to = safe_return_to(return_to_params)
    session[:return_to] = return_to if return_to.present?
  end

  def instantiate_sessions_presenter
    @presenter = Provider::SessionsPresenter.new(domain_account)
  end

  def bot_protection_level
    domain_account.settings.admin_bot_protection_level
  end
end
