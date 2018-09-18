class Provider::SignupsController < Provider::BaseController
  include ThreeScale::SpamProtection::Integration::Controller

  skip_before_action :set_x_frame_options_header
  before_action :ensure_signup_possible

  skip_before_action :login_required
  skip_before_action :enable_analytics, only: :test

  before_action :cors
  public :cors

  before_action :set_analytics_page
  before_action :handle_cache_response, only: :show

  layout 'provider/iframe'

  self.layoutless_rendering = false

  def show # original iframe form
    @provider = master.providers.build
    @user     = @provider.users.build_with_fields
    @plan     = plan
    @signup_origin = params[:origin] || params[:signup_origin]
    @fields = Fields::SignupForm.new(@provider, @user, params[:fields])
  end

  def create
    account_params = (params[:account] || {}) .dup
    user_params    = account_params.try!(:delete, :user)
    @plan = plan

    signup = master.signup_provider(plan, signup_options) do |provider, user|
      @provider, @user = provider, user

      @fields = Fields::SignupForm.new(@provider, @user, params[:fields])

      provider.attributes = account_params
      provider.subdomain  = account_params[:subdomain]

      user.attributes = user_params

      user.signup_type = :new_signup

      break unless spam_check(provider)
    end

    return render :show unless signup

    session[:success_data] = { first_name: @user.first_name, email: @user.email }

    tracking = ThreeScale::Analytics.user_tracking(@user)
    traits = tracking.identify(analytics_session.traits)
    analytics_session.delayed.identify(@user.id, traits)

    if request.xhr?
      render json: { redirect: success_provider_signup_url, success: true }
    else
      redirect_to success_provider_signup_path
    end
  end

  protected

  def handle_cache_response
    expires_in 1.hour, public: true
    fresh_when etag: params, last_modified: System::Application.config.boot_time
  end

  def set_analytics_page
    @analytics_page = { path: url_for(only_path: true), url: url_for }
  end

  def current_user
    nil # no one can't be logged in!
  end

  def signup_options
    { mkt_cookie: cookies[:_mkto_trk], analytics: analytics_session.traits }
  end

  def master
    site_account
  end

  def ensure_signup_possible
    unless master.signup_provider_possible?
      System::ErrorReporting.report_error("Provider signup not enabled. Check all master's plans are in place.")
      render_error 'Provider signup not enabled.', :status => :not_found
    end
  end

  def plan
    plan_ids = params[:plan_id].presence
    master.accessible_services.default.application_plans.published.find(plan_ids) if plan_ids
  end
end
