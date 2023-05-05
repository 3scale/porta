# frozen_string_literal: true

class Master::Api::ProvidersController < Master::Api::BaseController
  include ApiAuthentication::ByAccessToken

  wrap_parameters :account
  representer ::Signup::ResultWithAccessToken

  authenticate_access_token plain: 'unauthorized'
  self.access_token_scopes = :account_management
  before_action :ensure_master_with_plans, only: :create

  before_action :find_plan_for_upgrade, only: :plan_upgrade

  # Change the partner of a provider account
  #
  # Params:
  # - application_plan: system_name should be valid for the partner
  # - partner: system_name, could be nil
  # - api_key: API KEY of master account
  #
  # Description:
  #
  # Allow set or unset a partner for a provider account.
  def change_partner
    get_provider
    get_partner
    get_application_plan
    @provider.partner = @partner # could be nil
    @provider.save
    @provider.force_upgrade_to_provider_plan!(@application_plan)
    render json: @provider.as_json(include: [:bought_cinstance, :partner])
  end

  # Tenant Create
  # POST /master/api/providers.xml
  def create
    signup_result = Signup::ProviderAccountManager.new(current_account).create(create_params, ::Signup::ResultWithAccessToken)

    if signup_result.persisted?
      signup_result.account_approve! unless signup_result.account_approval_required?
      ProviderUserMailer.activation(signup_result.user).deliver_later
    end

    respond_with(signup_result)
  end

  # Tenant Update
  # PUT /master/api/providers/{id}.xml
  def update
    provider_account.assign_attributes(update_params, without_protection: true)
    provider_account.assign_unflattened_attributes(params.require(:account))
    provider_account.save

    respond_with signup_result_with_nil_token
  end

  # Tenant Delete
  # DELETE /master/api/providers/{id}.xml
  def destroy
    provider_account.schedule_for_deletion!
    respond_with provider_account
  end

  # Tenant Show
  # GET /master/api/providers/{id}.xml
  def show
    respond_with signup_result_with_nil_token
  end

  def plan_upgrade
    authorize! :update, :provider_plans
    authorize! :update, @plan_for_upgrade.issuer

    new_switches = provider_account.available_plans[@plan_for_upgrade.system_name]
    if new_switches
      provider_account.force_upgrade_to_provider_plan!(@plan_for_upgrade)
      respond_with signup_result_with_nil_token
    else
      render_error "Plan #{@plan_for_upgrade.name} is not one of the 3scale stock plans. Cannot automatically change to it.",
                   status: :bad_request
    end
  end

  UPDATE_PARAMS = %i[from_email support_email finance_support_email site_access_code state_event].freeze
  private_constant :UPDATE_PARAMS

  private

  def provider_account
    @provider_account ||= current_account.providers.without_deleted(!action_includes_deleted_providers?).find(params[:id])
  end

  def signup_result_with_nil_token
    signup_result = Signup::ResultWithAccessToken.new(account: provider_account, user: provider_account.admin_users.first)

    # Signup::ResultWithAccessToken because it is the representer, but after it initializes, it builds an access token,
    # which is a known design problem). So this access token needs to be set to nil before responding because it is an unsaved one
    signup_result.access_token = nil
    signup_result
  end

  def action_includes_deleted_providers?
    %w[show update].include?(action_name)
  end

  def ensure_master_with_plans
    return if current_account.signup_provider_possible?
    System::ErrorReporting.report_error('Provider signup not enabled. Check all master\'s plans are in place.')
    render_error 'Provider signup not enabled.', :status => :unprocessable_entity
  end

  def find_plan_for_upgrade
    plan_id = params[:plan_id]
    @plan_for_upgrade ||= Account.master.application_plans.stock.find(plan_id)
  rescue ActiveRecord::RecordNotFound
    render_error "Plan with ID #{plan_id.presence} not found", status: :not_found
  end

  def update_params
    permitted_params = provider_account.scheduled_for_deletion? ? %i[state_event] : UPDATE_PARAMS
    params.require(:account).permit(permitted_params)
  end

  def create_params
    defaults = { ApplicationPlan => { :name => 'API signup', :description => 'API signup', :create_origin => 'api' } }
    Signup::SignupParams.new(plans: plans, user_attributes: flat_params.merge(signup_type: :created_by_provider), account_attributes: flat_params, defaults: defaults)
  end

  def plans
    if ThreeScale.config.onpremises
      []
    else
      plan_ids = %i[service account application].map {|type| params["#{type}_plan_id"] }.compact
      plan_ids.present? ? current_account.provided_plans.where(id: plan_ids) : []
    end
  end

  def get_partner
    @partner = Partner.find_by_system_name(params[:partner])
  end

  def get_application_plan
    application_plans = Account.master.application_plans.where(partner_id: @partner.try!(:id))
    @application_plan = application_plans.find_by_system_name(params[:application_plan])
    raise ActiveRecord::RecordNotFound if @application_plan.blank?
  end

  def get_provider
    @provider = Account.providers.find(params[:id])
  end
end
