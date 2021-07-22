# frozen_string_literal: true

class DeveloperPortal::LoginController < DeveloperPortal::BaseController
  include ThreeScale::SpamProtection::Integration::Controller
  skip_before_action :login_required

  wrap_parameters :session, include: %i[username password remember_me]

  before_action :redirect_if_logged_in, :only => [ :new ]
  before_action :ensure_buyer_domain
  before_action :set_strategy
  skip_before_action :finish_signup_for_paid_plan

  activate_menu :root

  protect_from_forgery with: :exception
  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_forgery_protection

  liquify prefix: 'login'

  def new
    @session = Session.new
    session[:return_to] ||= params.delete(:return_to)
    assign_drops add_authentication_drops
  end

  def create
    logout_keeping_session!
    return render_creation_error('Spam protection failed.') unless spam_check(buyer)

    if sign_in_user
      self.current_user = @user
      create_user_session!
      flash[:notice] = @strategy.new_user_created? ? 'Signed up successfully' : 'Signed in successfully'
      redirect_back_or_default(@strategy.redirect_to_on_successful_login)
    elsif @strategy.redirects_to_signup?
      @strategy.on_signup(session)
      redirect_to @strategy.signup_path(params), notice: 'Successfully authenticated, please complete the signup form'
    else
      render_creation_error
    end
  end

  def destroy
    logout_killing_session!
    destroy_user_session!

    redirect_to root_url, notice: "You have been logged out."
  end

  private

  def buyer
    @buyer ||= site_account.buyers.build
  end

  def sign_in_user
    @user = @strategy.authenticate(params.merge(request: request))
  end

  def render_creation_error(error = @strategy.error_message)
    @session = Session.new
    flash.now[:error] = error
    assign_drops add_authentication_drops
    render action: :new
  end

  def redirect_if_logged_in
    redirect_to admin_dashboard_path if logged_in?
  end

  def set_strategy
    @strategy = Authentication::Strategy.build(site_account)
  end

  def add_authentication_drops(drops = {})
    case @strategy
    when Authentication::Strategy::Cas
      drops[:cas] = Liquid::Drops::AuthenticationStrategy::Cas.new(@strategy)
    end

    drops
  end

end
