class Admin::Api::Services::EndUsersController < Admin::Api::Services::BaseController
  representer ::EndUser
  before_action :authorize_end_users

  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/end_users/{username}.xml"
  ##~ e.responseClass = "end_user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "End User Read"
  ##~ op.description = "Returns the end user by ID."
  ##~ op.group = "end_user"
  #
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_end_user_username_by_id
  #
  def show
    respond_with(end_user)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/end_users.xml"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "End User Create"
  ##~ op.description = "Create an end user."
  ##~ op.group = "end_user"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_end_user_username_by_name
  ##~ op.parameters.add :name => "plan_id", :description => "ID of the end user plan. If not passed, the default end user plan will be used.", :dataType => "int", :paramType => "query"
  #
  def create
    end_user = EndUser.create(service, end_user_params)

    respond_with(end_user)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/end_users/{username}.xml"
  ##~ e.responseClass = "end_user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "End User Delete"
  ##~ op.description = "Deletes an end user."
  ##~ op.group = "end_user"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_end_user_username_by_id
  #
  def destroy
    end_user.destroy

    respond_with(end_user)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/end_users/{username}/change_plan.xml"
  ##~ e.responseClass = "end_user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "End User Change Plan"
  ##~ op.description = "Changes the end user plan of an end user."
  ##~ op.group = "end_user"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_end_user_username_by_id
  ##~ op.parameters.add :name => "plan_id", :description => "id of the new end user plan.", :dataType => "int", :paramType => "query", :required => true, :threescale_name => "end_user_plan_ids"
  #
  def change_plan
    end_user.plan = plan
    end_user.save

    respond_with(end_user)
  end

  private

  def end_user_params
    params.slice(*EndUser.accessible_attributes)
  end

  def end_user(id = params[:id])
    @end_user ||= EndUser.find(service, id) or raise(ActiveRecord::RecordNotFound, "Couldn't find EndUser with ID=#{id}")
  end

  def plan
    @plan ||= service.end_user_plans.find(params[:plan_id])
  end

  def authorize_end_users
    provider_can_use!(:end_users)
    authorize_switch! :end_users
  end
end
