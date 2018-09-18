# frozen_string_literal: true

class DeveloperPortal::LoginController < DeveloperPortal::BaseController
  skip_before_action :login_required

  wrap_parameters :session, include: %i[username password remember_me]

  before_action :redirect_if_logged_in, :only => [ :new ]
  before_action :ensure_buyer_domain
  before_action :set_strategy
  skip_before_action :finish_signup_for_paid_plan

  activate_menu :root

  # you can't exploit CSRF if a user is not logged in
  protect_from_forgery :except => :create

  liquify prefix: 'login'

  def new
    @session = Session.new
    session[:return_to] ||= params.delete(:return_to)
    assign_drops add_authentication_drops
  end

  def create
    logout_keeping_session!

    if (@user = @strategy.authenticate(params.merge(request: request)))
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

  def render_creation_error
    @session = Session.new
    flash.now[:error] = @strategy.error_message
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
