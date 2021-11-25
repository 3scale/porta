class Partners::ProvidersController < Partners::BaseController

  before_action :find_account, only: [:destroy, :update]

  def create
    partner_system_name = partner.system_name

    signup_result = Signup::ProviderAccountManager.new(Account.master).create(signup_params) do |result|
      account = result.account
      account.signup_mode!
      account.subdomain = "#{params.require(:subdomain)}-#{partner_system_name}"
      account.generate_domains!
      account.partner = partner
      account.extra_fields['partner'] = partner_system_name
      account.settings.monthly_charging_enabled = false
    end
    @account = signup_result.account
    @user = signup_result.user

    if signup_result.persisted?
      signup_result.user_activate!
      tracking = ThreeScale::Analytics.user_tracking(@user)
      tracking.identify({})
      tracking.track('Signup', {})
      render json: {id: @account.id, provider_key: @account.api_key, end_point: @account.self_domain, success: true}
    else
      render json: {errors: {user: @user.errors, account: @account.errors}, success: false}, status: :unprocessable_entity
    end
  end

  def update
    @account.force_to_change_plan!(selected_plan)
    render json: {id: @account.id, message: "Plan changed", success: true}
  end

  def destroy
    @account.destroy
    render json: { success: true }
  end

  private

  def signup_params
    Signup::SignupParams.new(plans: [selected_plan], user_attributes: user_params, account_attributes: account_params, validate_fields: true)
  end

  def account_params
    {
      org_name: "#{partner.system_name}-#{params.require(:org_name)}",
      sample_data: true,
      partner: partner,
      provider: true
    }
  end

  def user_params
    {
      signup_type: partner.signup_type,
      password: params.require(:password).presence || SecureRandom.hex,
      email: params.require(:email),
      first_name: params.require(:first_name),
      last_name: params.require(:last_name),
      username: 'admin'
    }.tap do |parameters|
      open_id = params.require(:open_id)
      parameters[:open_id] = open_id if open_id.present?
    end
  end

  def find_account
    @account = @partner.providers.find(params.require(:id))
  end

  def application_plans
    @application_plans ||= @partner.application_plans
  end

  def selected_plan
    if @selected_plan = application_plans.find_by_system_name(params.require(:application_plan))
      @selected_plan
    else
      application_plans.first
    end
  end

end
