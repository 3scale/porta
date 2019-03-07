class Admin::Api::Services::EndUserPlansController < Admin::Api::EndUserPlansController
  before_action :authorize_end_user_plans
  ##~ sapi = source2swagger.namespace("Account Management API")

  # inherited index action
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/end_user_plans.xml"
  ##~ e.responseClass = "List[end_user_plan]"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "End User Plan List"
  ##~ op.description = "Returns the list of all end user plans of a service."
  ##~ op.group = "end_user_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name


  ##~ op = e.operations.add
  ##~ e.path = "/admin/api/services/{service_id}/end_user_plans.xml"
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "End User Plan Create"
  ##~ op.description = "Creates an end user plan."
  ##~ op.group = "end_user_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add :name => "name", :description => "Name of the end user plan.", :dataType => "string", :required => true, :paramType => "query"
  #
  def create
    # calling end_user_plans.create hits rails bug and before the save 'service' object will be different
    # because inverse_of is set after the object is saved - https://github.com/rails/rails/pull/9996
    end_user_plan = end_user_plans.new(end_user_plan_params)
    end_user_plan.save

    respond_with(end_user_plan)
  end

  # -----------------

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/end_user_plans/{id}.xml"
  ##~ e.responseClass = "end_user_plan"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "End User Plan Read"
  ##~ op.description = "Returns an end user plan."
  ##~ op.group = "end_user_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_end_user_plan_id_by_id
  #
  def show
    respond_with(end_user_plan)
  end

  ##~ op = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "End User Plan Update"
  ##~ op.description = "Updates an end user plan."
  ##~ op.group = "end_user_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_end_user_plan_id_by_id
  ##~ op.parameters.add :name => "name", :description => "Name of the end user plan.", :dataType => "string", :required => true, :paramType => "query"
  #
  def update
    end_user_plan.update_attributes(end_user_plan_params)

    respond_with(end_user_plan)
  end

  ##~ e = sapi.apis.add
  ##~ e.path   = "/admin/api/services/{service_id}/end_user_plans/{id}/default.xml"
  ##~ e.responseClass = "end_user_plan"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "End User Plan Set to Default"
  ##~ op.description = "Makes the end user plan the default one. New end users will be assigned to the default plan unless an end_user_plan_id is explicity passed on end user creation."
  ##~ op.group = "end_user_plan"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_end_user_plan_id_by_id
  #
  def default
    end_user_plan.default!
    respond_with(end_user_plan)
  end

  private

  def authorize_end_users
    provider_can_use!(:end_users)
  end

  def end_user_plan_params
    params.slice(*EndUserPlan.accessible_attributes)
  end

  def end_user_plans
    @end_user_plans ||= service.end_user_plans
  end

  def end_user_plan
    @end_user_plan ||= end_user_plans.find(params[:id])
  end

  def service
    @service ||= accessible_services.find(params[:service_id])
  end
end
