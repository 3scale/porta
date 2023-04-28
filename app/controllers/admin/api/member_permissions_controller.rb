# frozen_string_literal: true

class Admin::Api::MemberPermissionsController < Admin::Api::BaseController

  represents :json, collection: ::MemberPermissionsRepresenter::JSON
  represents :xml, collection: ::MemberPermissionsRepresenter::XML

  wrap_parameters :permissions, include: %i[allowed_sections allowed_service_ids]

  self.access_token_scopes = :account_management

  # User Permissions Read
  # GET /admin/api/users/{id}/permissions.xml
  def show
    authorize! :show, user

    respond_with user.member_permissions, user: user
  end

  # User Permissions Update
  # PUT /admin/api/users/{id}/permissions.xml
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
    # both `:allowed_service_ids` and `allowed_service_ids: []` are required for service IDs
    # because we want to allow empty value (`allowed_service_ids%5B%5D=%5B%5D`) and
    # 'nil' value (`allowed_service_ids%5B%5D` or just `allowed_service_ids`)
    params.require(:permissions).permit(:allowed_service_ids, allowed_service_ids: [], allowed_sections: [])
  end

end
