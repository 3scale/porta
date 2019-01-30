# frozen_string_literal: true

class Admin::Api::ApplicationPlansController < Admin::Api::ServiceBaseController
  representer ApplicationPlan
  wrap_parameters ApplicationPlan, include: ApplicationPlan.attribute_names | %w[state_event]

  before_action :deny_on_premises_for_master
  before_action :authorize_manage_plans, only: %i[create destroy]

  ##~ @parameter_application_plan_state_event = {:name => "state_event", :description => "State event of the application plan. It can be 'publish' or 'hide'", :dataType => "string", :required => false, :paramType => "query"}

  # swagger (this is the unnested "fast track" route to get all app_plans)
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/application_plans.xml"
  ##~ e.responseClass = "List[application_plan]"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Application Plan List (all services)"
  ##~ op.description = "Returns the list of all application plans across services. Note that application plans are scoped by service."
  ##~ op.group = "application_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/application_plans.xml"
  ##~ e.responseClass = "List[application_plan]"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Application Plan List"
  ##~ op.description = "Returns the list of all application plans of a service."
  ##~ op.group = "application_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  #
  def index
    respond_with(application_plans)
  end

  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Application Plan Create"
  ##~ op.description = "Creates an application plan."
  ##~ op.group = "application_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add :name => "name", :description => "Name of the application plan.", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "approval_required", :description => "Set the 'Applications require approval?' to 'true' or 'false'", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add @parameter_system_name_by_name
  ##~ op.parameters.add @parameter_application_plan_state_event
  #
  def create
    application_plan = application_plans.create(application_plan_create_params)
    respond_with(application_plan)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/application_plans/{id}.xml"
  ##~ e.responseClass = "application_plan"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Application Plan Read"
  ##~ op.description = "Returns and application plan."
  ##~ op.group = "application_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_application_plan_id_by_id
  #
  def show
    respond_with(application_plan)
  end

  ##~ op = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Application Plan Update"
  ##~ op.description = "Updates an application plan."
  ##~ op.group = "application_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_application_plan_id_by_id
  ##~ op.parameters.add :name => "name", :description => "Name of the application plan.", :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "approval_required", :description => "Set the 'Applications require approval?' to 'true' or 'false'", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add @parameter_application_plan_state_event
  #
  def update
    application_plan.update_attributes(application_plan_update_params)
    respond_with(application_plan)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Application Plan Delete"
  ##~ op.description = "Deletes an application plan."
  ##~ op.group = "application_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_application_plan_id_by_id
  #
  def destroy
    application_plan.destroy

    respond_with(application_plan)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path   = "/admin/api/services/{service_id}/application_plans/{id}/default.xml"
  ##~ e.responseClass = "application_plan"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Application Plan Set to Default"
  ##~ op.description = "Makes the application plan the default one. New applications will be assigned to the default plan unless an application_plan_id is explicity passed (e.g. on the signup express operation)."
  ##~ op.group = "application_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_application_plan_id_by_id
  #
  def default
    service.update_attribute(:default_application_plan, application_plan)
    respond_with(application_plan)
  end

  protected

  DEFAULT_PARAMS = %i[name state_event description approval_required].freeze

  def application_plan_update_params
    params.require(:application_plan).permit(DEFAULT_PARAMS)
  end

  def application_plan_create_params
    params.require(:application_plan).permit(DEFAULT_PARAMS | %i[system_name])
  end

  def application_plans
    @application_plans ||= scope.application_plans.where(issuer: accessible_services)
  end

  def application_plan
    @application_plan ||= application_plans.find(params[:id])
  end

  def authorize_manage_plans
    Ability.new(current_account.admins.first).authorize!(:manage, :plans)
  end
end
