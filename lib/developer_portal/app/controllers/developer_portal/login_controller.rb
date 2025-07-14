# frozen_string_literal: true

class DeveloperPortal::LoginController < DeveloperPortal::BaseController
  include ThreeScale::BotProtection::Controller

  skip_before_action :login_required

  wrap_parameters :session, include: %i[username password remember_me]

  before_action :redirect_if_logged_in, :only => [ :new ]
  before_action :ensure_buyer_domain
  before_action :set_strategy
  skip_before_action :finish_signup_for_paid_plan

  activate_menu :root

  liquify prefix: 'login'

  def new
    @session = Session.new
    session[:return_to] ||= params.delete(:return_to)
    assign_drops add_authentication_drops
  end

  def create
    logout_keeping_session!

    return render_login_error if @strategy.bot_protected? && !bot_check

    if (@user = @strategy.authenticate(auth_params))
      self.current_user = @user
      create_user_session!
      flash[:notice] = @strategy.new_user_created? ? 'Signed up successfully' : 'Signed in successfully'

      redirect_back_or_default(@strategy.redirect_to_on_successful_login)
    elsif @strategy.redirects_to_signup?
      @strategy.on_signup(session)

      redirect_to @strategy.signup_path(params), notice: 'Successfully authenticated, please complete the signup form'
    else
      attempted_cred = params.fetch(:username, 'SSO')
      AuditLogService.call("Login attempt failed: #{request.internal_host} - #{attempted_cred}")

      render_login_error(@strategy.error_message)
    end
  end

  def destroy
    logout_killing_session!
    destroy_user_session!

    redirect_to root_url, notice: "You have been logged out."
  end

  private

  def auth_params
    params.permit(*%i[username password ticket token expires_at redirect_url system_name code]).merge(request:)
  end

  def render_login_error(error_message = nil)
    @session = Session.new
    flash.now[:error] = error_message if error_message
    assign_drops add_authentication_drops
    render action: :new
  end

  def redirect_if_logged_in
    redirect_to admin_dashboard_path if logged_in?
  end

  def set_strategy
    @strategy = Authentication::Strategy::InferService.call(auth_params, site_account).result
  end

  def add_authentication_drops(drops = {})
    case @strategy
    when Authentication::Strategy::Cas
      drops[:cas] = Liquid::Drops::AuthenticationStrategy::Cas.new(@strategy)
    end

    drops
  end
end
