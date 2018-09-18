# frozen_string_literal: true

class Admin::Api::ServicePlansController < Admin::Api::ServiceBaseController
  wrap_parameters ServicePlan, include: ServicePlan.attribute_names | %w[state_event]
  representer ServicePlan

  before_action :authorize_service_plans!

  ##~ @parameter_service_plan_state_event = {:name => "state_event", :description => "State event of the service plan. It can be 'publish' or 'hide'", :dataType => "string", :required => false, :paramType => "query"}

  # swagger (this is the unnested "fast track" route to get all service_plans)
  ##~ sapi = source2swagger.namespace("Account Management API")
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/service_plans.xml"
  ##~ e.responseClass = "List[service_plan]"
  ##~ e.description   = "Returns a list of all your service plans."
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Service Plan List (all services)"
  ##~ op.description = "Returns a list of all service plans for all services. Note that service plans are scoped by service."
  ##~ op.group = "service_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{id}/service_plans.xml"
  ##~ e.responseClass = "List[service_plan]"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Service Plan List"
  ##~ op.description   = "Returns a list of all service plans for a service."
  ##~ op.group = "service_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id
  #
  def index
    respond_with(service_plans)
  end

  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary = "Service Plan Create"
  ##~ op.description = "Creates a new service plan in a service."
  ##~ op.group = "service_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id
  ##~ op.parameters.add :name => "name", :description => "Name of the service plan.", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add @parameter_system_name_by_name
  ##~ op.parameters.add @parameter_service_plan_state_event
  #
  def create
    service_plan = service_plans.create(service_plan_create_params)
    respond_with(service_plan)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/service_plans/{id}.xml"
  ##~ e.responseClass = "service_plan"
  #
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Service Plan Read"
  ##~ op.description = "Returns a service plan by ID."
  ##~ op.group = "service_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_service_plan_id_by_id
  #
  def show
    respond_with(service_plan)
  end

  ##~ op = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Service Plan Update"
  ##~ op.description = "Updates a service plan by ID."
  ##~ op.group = "service_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_service_plan_id_by_id
  ##~ op.parameters.add :name => "name", :description => "Name of the service plan.", :dataType => "string", :required => false, :paramType => "query"
  ##~ op.parameters.add @parameter_service_plan_state_event
  #
  def update
    service_plan.update_attributes(service_plan_update_params)
    respond_with(service_plan)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Service Plan Delete"
  ##~ op.description = "Deletes a service plan by ID."
  ##~ op.group = "service_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_service_plan_id_by_id
  #
  def destroy
    service_plan.destroy

    respond_with(service_plan)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/service_plans/{id}/default.xml"
  ##~ e.responseClass = "service_plan"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Service Plan Set to Default"
  ##~ op.description = "Sets the service plan as default. The default service plan is used when no explicit service plan is used."
  ##~ op.group = "service_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_service_plan_id_by_id
  #
  def default
    service.update_attribute(:default_service_plan, service_plan)

    respond_with(service_plan)
  end

  protected

  DEFAULT_PARAMS = %i[name state_event].freeze

  def service_plan_update_params
    params.require(:service_plan).permit(DEFAULT_PARAMS)
  end

  def service_plan_create_params
    params.require(:service_plan).permit(DEFAULT_PARAMS | %i[system_name])
  end

  def service_plans
    @service_plans ||= scope.service_plans.where(issuer: accessible_services)
  end

  def service_plan
    @service_plan ||= service_plans.find(params[:id])
  end

end
