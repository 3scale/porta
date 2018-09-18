class Admin::Api::UsersController < Admin::Api::BaseController
  representer User

  before_action :can_create, only: :create

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/users.xml"
  ##~ e.responseClass = "List[users]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "User List (provider account)"
  ##~ op.description = "Lists the users of the provider account. You can apply filters by state and/or role."
  ##~ op.group = "user_provider_account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_user_state
  ##~ op.parameters.add @parameter_user_role
  #
  def index
    authorize! :manage, :multiple_users

    respond_with(users)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "User Create (provider account)"
  ##~ op.description = "Creates a new user in the provider account. Do not forget to activate it, otherwise he/she will not be able to sign-in. After creation the default state is pending and the default role is member. The user object can be extended using Fields Definitions in the Admin Portal where you can add/remove fields, for instance token (string), age (int), third name (string optional), etc."
  ##~ op.group = "user_provider_account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "username", :description => "Username of the user.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "email", :description => "Email of the user.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "password", :description => "Password of the user.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add @parameter_extra_provider
  #
  def create
    user = new_user

    authorize! :create, user

    user.unflattened_attributes = flat_params
    user.signup_type = :api

    user.save

    respond_with(user)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/users/{id}.xml"
  ##~ e.responseClass = "user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "User Read (provider account)"
  ##~ op.description = "Gets the user of the provider account by ID."
  ##~ op.group = "user_provider_account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_admin_id_by_id
  #
  def show
    authorize! :show, user

    respond_with(user)
  end

  # swagger
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "User Update (provider account)"
  ##~ op.description = "Modifies the user of the provider account by ID. You can update any field, not only those in the form of the ActiveDocs but also fields that belong to the User object. Remember that you can define custom fields on your Admin Portal."
  ##~ op.group = "user_provider_account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_admin_id_by_id
  ##~ op.parameters.add :name => "username", :description => "Username of the user.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "email", :description => "Email of the user.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "password", :description => "Password of the user.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add @parameter_extra_provider
  #
  def update
    authorize! :update, user

    user.update_with_flattened_attributes(flat_params, as: current_user.try(:role))

    respond_with(user)
  end

  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "User Delete (provider account)"
  ##~ op.description = "Deletes the user of the provider account by ID."
  ##~ op.group = "user_provider_account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_admin_id_by_id
  #
  def destroy
    authorize! :destroy, user

    user.destroy

    respond_with(user)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/users/{id}/member.xml"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "User Change Role to Member (provider account)"
  ##~ op.description = "Changes the role of the user of the provider account to member."
  ##~ op.group = "user_provider_account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_admin_id_by_id
  #
  def member
    authorize! :update_role, user

    user.make_member

    respond_with(user)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/users/{id}/admin.xml"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "User Change Role to Admin (provider account)"
  ##~ op.description = "Changes the role of the provider account to admin (full rights and privileges)."
  ##~ op.group = "user_provider_account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_admin_id_by_id
  #
  def admin
    authorize! :update_role, user

    user.make_admin

    respond_with(user)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/users/{id}/suspend.xml"
  ##~ e.responseClass = "user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "User Suspend (provider account)"
  ##~ op.description = "Changes the state of the user of the provider account to suspended, which removes the user's ability to sign-in. You can also perform this operation with a PUT on /admin/api/users/{id}.xml to change the state parameter."
  ##~ op.group = "user_provider_account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_admin_id_by_id
  #
  def suspend
    authorize! :suspend, user

    user.suspend!

    respond_with(user)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/users/{id}/unsuspend.xml"
  ##~ e.responseClass = "user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "User Unsuspend (provider account)"
  ##~ op.description = "Revokes the suspension of a user of the provider account. You can also perform this operation with a PUT on /admin/api/users/{id}.xml to change the state parameter."
  ##~ op.group = "user_provider_account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_admin_id_by_id
  #
  def unsuspend
    authorize! :unsuspend, user

    user.unsuspend

    respond_with(user)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/users/{id}/activate.xml"
  ##~ e.responseClass = "user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "User Activate (provider account)"
  ##~ op.description = "Changes the state of the user of the provider account to active (after sign-up). You can also perform this operation with a PUT on /admin/api/users/{id}.xml to change the state parameter."
  ##~ op.group = "user_provider_account"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_admin_id_by_id
  #
  def activate
    authorize! :update, user

    user.activate

    respond_with(user)
  end

  protected

  def authorize!(*args)
    current_user ? super : logged_in?
  end

  def new_user
    @new_user ||= current_account.users.new
  end

  def users
    @users ||= begin
      conditions = params.slice(:state, :role)
      current_account.users.but_impersonation_admin.where(conditions)
    end
  end

  def user
    @user ||= current_account.users.but_impersonation_admin.find(params[:id])
  end

  def can_create
    head :forbidden unless current_account.can_create_user?
  end
end
