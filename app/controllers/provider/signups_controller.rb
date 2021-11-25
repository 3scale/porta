# frozen_string_literal: true

class Provider::SignupsController < Provider::BaseController
  include ThreeScale::SpamProtection::Integration::Controller

  before_action :disable_x_frame
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
    @signup_origin = default_params.require(:origin) || default_params.require(:signup_origin)
    @fields = Fields::SignupForm.new(@provider, @user, default_params.require(:fields))
  end

  def create
    @plan = plan
    provider_account_manager = Signup::ProviderAccountManager.new(master)
    signup_result = provider_account_manager.create(signup_params, &method(:build_signup_result_custom_fields))
    @fields = Fields::SignupForm.new(@provider, @user, default_params.require(:fields))

    return render :show unless signup_result.persisted?

    session[:success_data] = { first_name: @user.first_name, email: @user.email }

    tracking = ThreeScale::Analytics.user_tracking(@user)
    traits = tracking.identify(analytics_session.traits)
    tracking.track('Signup', signup_options)
    analytics_session.delayed.identify(@user.id, traits)

    if request.xhr?
      render json: { redirect: success_provider_signup_url, success: true }
    else
      redirect_to success_provider_signup_path
    end
  end

  protected

  def signup_params
    Signup::SignupParams.new(plans: [plan], user_attributes: user_params, account_attributes: account_params, validate_fields: true)
  end

  def account_params
    params.require(:account).except(:user).merge(sample_data: true)
  end

  def user_params
    params.require(:account).fetch(:user, {}).merge(signup_type: :new_signup, username: :admin)
  end

  def handle_cache_response
    expires_in 1.hour, public: true
    fresh_when etag: default_params, last_modified: System::Application.config.boot_time
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
    return if master.signup_provider_possible?

    System::ErrorReporting.report_error('Provider signup not enabled. Check all master\'s plans are in place.')
    render_error 'Provider signup not enabled.', status: :not_found
  end

  def build_signup_result_custom_fields(result)
    @provider = result.account
    @user = result.user
    @provider.signup_mode!
    @provider.subdomain = account_params.require(:subdomain)
    @provider.self_subdomain = account_params.require(:self_subdomain)
    result.add_error(message: 'spam check failed') unless spam_check(@provider)
  end

  def plan
    plan_ids = default_params.require(:plan_id).presence
    master.accessible_services.default.application_plans.published.find(plan_ids) if plan_ids
  end

  def default_params
    # permit all since it can have multiple different and dynamic data
    params.permit!.to_h
  end
end
