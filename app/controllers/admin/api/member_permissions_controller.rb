# frozen_string_literal: true

class Admin::Api::MemberPermissionsController < Admin::Api::BaseController

  represents :json, collection: ::MemberPermissionsRepresenter::JSON
  represents :xml, collection: ::MemberPermissionsRepresenter::XML

  wrap_parameters :permissions, include: %i[allowed_sections allowed_service_ids]

  self.access_token_scopes = :account_management

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/users/{id}/permissions.xml"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "User Permissions Read"
  ##~ op.description = "Shows the permissions of the user of the provider account."
  ##~ op.group = "user_provider_account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_admin_id_by_id
  #
  def show
    authorize! :show, user

    respond_with user.member_permissions, user: user
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/users/{id}/permissions.xml"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "User Permissions Update"
  ##~ op.description = "Updates the permissions of member user of the provider account."
  ##~ op.group = "user_provider_account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_admin_id_by_id
  ##~ op.parameters.add :name => "allowed_service_ids", :description => "IDs of the services that need to be enabled, comma-separated. To enable all services, the value should be empty. To disable all services, the value should be: '[]'.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "allowed_sections", :description => "The list of sections in the admin portal that the user can access, comma-separated. Possible values: 'portal' (Developer Portal), 'finance' (Billing), 'settings', 'partners' (Developer Accounts -- Applications), 'monitoring' (Analytics), 'plans' (Integration & Application Plans)", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  #
  def update
    authorize! :update_permissions, user

    if user.update_attributes(permission_params)
      respond_with user.member_permissions, user: user
    else
      # errors are stored in the 'user' model
      respond_with(user)
    end
  end

  protected

  def authorize!(*args)
    current_user ? super : logged_in?
  end

  def user
    @user ||= current_account.users.find(params[:id])
  end

  def permission_params
    params.require(:permissions).permit(allowed_service_ids: [], allowed_sections: [])
  end

end
