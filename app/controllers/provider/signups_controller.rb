# frozen_string_literal: true

class Provider::SignupsController < Provider::BaseController
  include ThreeScale::BotProtection::Controller

  before_action :disable_x_frame
  before_action :ensure_signup_possible

  skip_before_action :login_required

  before_action :cors
  public :cors

  before_action :set_analytics_page
  before_action :handle_cache_response, only: :show
  before_action :init_account_manager, only: :create

  layout 'provider/iframe'

  self.layoutless_rendering = false

  def show
    @provider = master.providers.build
    @user     = @provider.users.build_with_fields
    @signup_origin = params[:origin] || params[:signup_origin]
    @fields = Fields::SignupForm.new(@provider, @user, params[:fields])
  end

  def create
    signup_result = @account_manager.create(**signup_params) { |result| build_signup_result_custom_fields(result) }
    @fields = Fields::SignupForm.new(@provider, @user, params[:fields])

    return render :show unless signup_result.persisted?

    session[:success_data] = { first_name: @user.first_name, email: @user.email }

    track_user

    if request.xhr?
      render json: { redirect: success_provider_signup_url, success: true }
    else
      redirect_to success_provider_signup_path
    end
  end

  protected

  def signup_params
    {
      plans: [plan],
      validate_fields: true,
      account_params: account_params.merge(sample_data: true),
      user_params: user_params.merge(signup_type: :new_signup, username: :admin)
    }
  end

  def account_params
    account = @account_manager.account
    allowed_attrs = account.defined_builtin_fields_names + %w[name subdomain self_subdomain]
    params.require(:account).permit(*allowed_attrs, extra_fields: account.defined_extra_fields_names)
  end

  def user_params
    params.require(:account).fetch(:user, {}).permit(:first_name, :last_name, :email, :password)
  end

  def handle_cache_response
    expires_in 1.hour, public: true
    fresh_when etag: params.permit!.to_h, last_modified: System::Application.config.boot_time
  end

  def set_analytics_page
    @analytics_page = { path: url_for(only_path: true), url: url_for }
  end

  def current_user
    nil # no one can't be logged in!
  end

  def master
    site_account
  end

  def ensure_signup_possible
    return if master.provider_signup_form_enabled?

    System::ErrorReporting.report_error('Provider signup not enabled.')
    render_error 'Provider signup not enabled.', status: :not_found
  end

  def build_signup_result_custom_fields(result)
    @provider = result.account
    @user = result.user
    @provider.signup_mode!
    @provider.subdomain = account_params[:subdomain]
    @provider.self_subdomain = account_params[:self_subdomain]
    result.add_error(message: 'bot check failed') unless bot_check
  end

  def plan
    @plan ||= begin
      plan_ids = params[:plan_id].presence
      master.accessible_services.default.application_plans.published.find(plan_ids) if plan_ids
    end
  end

  def init_account_manager
    @account_manager = Signup::ProviderAccountManager.new(master)
  end

  def track_user
    tracking = ThreeScale::Analytics.user_tracking(@user)
    traits = tracking.identify(analytics_session.traits)
    signup_options = { mkt_cookie: cookies[:_mkto_trk], analytics: analytics_session.traits }
    tracking.track('Signup', signup_options)
    analytics_session.delayed.identify(@user.id, traits)
  end
end
