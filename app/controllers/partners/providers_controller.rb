class Partners::ProvidersController < Partners::BaseController

  before_action :find_account, only: [:destroy, :update]

  def create
    signup = Account.master.signup_provider(selected_plan) do |provider, user|
      @account, @user = provider, user
      provider.subdomain = "#{params[:subdomain]}-#{@partner.system_name}"
      provider.org_name = "#{@partner.system_name}-#{params[:org_name]}"
      provider.sample_data = true
      provider.settings.monthly_charging_enabled = false
      provider.extra_fields['partner'] = @partner.system_name
      provider.partner = @partner

      user.signup_type = @partner.signup_type

      user.password = params[:password].presence || SecureRandom.hex
      user.email = params[:email]
      user.first_name = params[:first_name]
      user.last_name = params[:last_name]
      user.open_id = params[:open_id] if params[:open_id].present?

    end

    if signup
      @user.activate!
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

  def find_account
    @account = @partner.providers.find(params[:id])
  end

  def application_plans
    @application_plans ||= @partner.application_plans
  end

  def selected_plan
    if @selected_plan = application_plans.find_by_system_name(params[:application_plan])
      @selected_plan
    else
      application_plans.first
    end
  end

end
