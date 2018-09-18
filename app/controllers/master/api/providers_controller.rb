# frozen_string_literal: true

class Master::Api::ProvidersController < Master::Api::BaseController
  include ApiAuthentication::ByAccessToken

  wrap_parameters :account
  representer ::Signup::ResultWithAccessToken

  authenticate_access_token plain: 'unauthorized'
  self.access_token_scopes = :account_management
  before_action :ensure_master_with_plans, only: :create

  ##~ @parameter_account_id_by_id = {:name => "id", :description => "ID of the account.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "account_ids"}

  # Change the partner of a provider account
  #
  # Params:
  # - application_plan: system_name should be valid for the partneter
  # - partner: system_name, could be nil
  # - api_key: API KEY of master account
  #
  # Description:
  #
  # Allow set or unset a partner for a provider account.
  # Could be used to move heroku providers to normal application plans
  # and move to heroku again.
  #
  # For heroku accounts we save some data in account.settings, this data
  # is not deleted.
  #
  # You should not move normal providers to heroku accounts because need
  # some special data that is provider for heroku when create an account.
  def change_partner
    get_provider
    get_partner
    get_application_plan
    @provider.partner = @partner # could be nil
    @provider.save
    @provider.force_upgrade_to_provider_plan!(@application_plan)
    render json: @provider.as_json(include: [:bought_cinstance, :partner])
  end

  # swagger
  ##~ @base_path = ""
  #
  ##~ sapi = source2swagger.namespace("Master API")
  ##~ sapi.basePath     = @base_path
  ##~ sapi.swaggerVersion = "0.1a"
  ##~ sapi.apiVersion   = "1.0"
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/master/api/providers.xml"
  ##~ e.responseClass = "signup"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary = "Tenant Create"
  ##~ op.description = "This request allows you to reproduce a sign-up from a tenant in a single API call. It will create an Account, an Admin User for the account, and optionally an Application with its keys. If the plan_id is not passed, the default plan will be used instead. You can add additional custom parameters in Fields Definition on your Admin Portal."
  ##~ op.group = "signup"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "org_name", :description => "Organization Name of the tenant account.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "username", :description => "Username of the admin user (on the new tenant account).", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "email", :description => "Email of the admin user.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "password", :description => "Password of the admin user.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add @parameter_extra
  #
  def create
    signup_result = Signup::ProviderAccountManager.new(current_account).create(create_params, ::Signup::ResultWithAccessToken)

    if signup_result.persisted?
      signup_result.account_approve! unless signup_result.account_approval_required?
      ProviderUserMailer.activation(signup_result.user).deliver_now
    end

    respond_with(signup_result)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/master/api/providers/{id}.xml"
  ##~ e.responseClass = "provider"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary = "Tenant Update"
  ##~ op.description = "Updates email addresses used to deliver email notifications to customers."
  ##~ op.group = "account"
  #
  ##~ @parameter_from_email = {:name => "from_email", :description => "New outgoing email.", :dataType => "string", :paramType => "query"}
  ##~ @parameter_support_email = {:name => "support_email", :description => "New support email.", :dataType => "string", :paramType => "query"}
  ##~ @parameter_finance_support_email = {:name => "finance_support_email", :description => "New finance support email.", :dataType => "string", :paramType => "query"}
  ##~ @parameter_site_access_code = {:name => "site_access_code", :description => "Developer Portal Access Code.", :dataType => "string", :paramType => "query"}
  ##~ @parameter_state_event = {:name => "state_event", :description => "Change the state of the tenant. It can be either 'make_pending', 'approve', 'reject', 'suspend', or 'resume' depending on the current state", :dataType => "string", :required => false, :paramType => "query"}
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id
  ##~ op.parameters.add @parameter_from_email
  ##~ op.parameters.add @parameter_support_email
  ##~ op.parameters.add @parameter_finance_support_email
  ##~ op.parameters.add @parameter_site_access_code
  ##~ op.parameters.add @parameter_state_event
  ##~ op.parameters.add @parameter_extra
  #
  def update
    provider_account.assign_attributes(update_params, without_protection: true)
    provider_account.assign_unflattened_attributes(params.require(:account))
    provider_account.save

    signup_result = Signup::ResultWithAccessToken.new(account: provider_account, user: provider_account.admin_users.first)

    # Signup::ResultWithAccessToken because it is the representer, but after it initializes, it builds an access token,
    # which is a known design problem). So this access token needs to be set to nil before responding because it is an unsaved one
    signup_result.access_token = nil

    respond_with signup_result
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/master/api/providers/{id}.xml"
  ##~ e.responseClass = "provider"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Tenant Delete"
  ##~ op.description = "Schedules a tenant account to be permanently deleted in 15 days. At that time all its users, services, plans and developer accounts subscribed to it will be deleted too. When a tenant account is scheduled for deletion it can no longer be edited (except except its state) and its admin portal and developer portal cannot be accessible. Update with 'resume' state event to unschedule a tenant for deletion."
  ##~ op.group = "account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id
  #
  def destroy
    provider_account.schedule_for_deletion!
    respond_with provider_account
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/master/api/providers/{id}.xml"
  ##~ e.responseClass = "provider"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary = "Tenant Show"
  ##~ op.description = "Show a tenant account."
  ##~ op.group = "account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id
  #
  def show
    signup_result = Signup::ResultWithAccessToken.new(account: provider_account, user: provider_account.admin_users.first)

    # Signup::ResultWithAccessToken because it is the representer, but after it initializes, it builds an access token,
    # which is a known design problem). So this access token needs to be set to nil before responding because it is an unsaved one
    signup_result.access_token = nil

    respond_with signup_result
  end

  UPDATE_PARAMS = %i[from_email support_email finance_support_email site_access_code state_event].freeze
  private_constant :UPDATE_PARAMS

  private

  def provider_account
    @provider_account ||= current_account.providers.without_deleted(!action_includes_deleted_providers?).find(params[:id])
  end

  def action_includes_deleted_providers?
    %w[show update].include?(action_name)
  end

  def ensure_master_with_plans
    return if current_account.signup_provider_possible?
    System::ErrorReporting.report_error('Provider signup not enabled. Check all master\'s plans are in place.')
    render_error 'Provider signup not enabled.', :status => :unprocessable_entity
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
