class Admin::Api::BuyersUsersController < Admin::Api::BuyersBaseController
  representer User

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/users.xml"
  ##~ e.responseClass = "List[users]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "User List"
  ##~ op.description = "Returns the list of users of an account. The list can be filtered by the state or role of the users."
  ##~ op.group = "user"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_user_state
  ##~ op.parameters.add @parameter_user_role
  #
  def index
    authorize! :manage, :multiple_users

    respond_with(users)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/users.xml"
  ##~ e.responseClass = "user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "User Create"
  ##~ op.description = "Creates a new user of the account (account_id). Do not forget to activate the user otherwise he/she will be unable to sign-in. After creation the default state is pending and the default role is member. The user object can be extended using Fields Definitions in the Admin Portal. You can add/remove fields, for instance token (string), age (int), third name (string optional), etc. "
  ##~ op.group = "user"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add :name => "username", :description => "Username of the user.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "email", :description => "Email of the user.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "password", :description => "Password of the user.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add @parameter_extra
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
  ##~ e.path = "/admin/api/accounts/{account_id}/users/{id}.xml"
  ##~ e.responseClass = "user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "User Read"
  ##~ op.description = "Returns the user of an account."
  ##~ op.group = "user"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_user_id_by_id
  #
  def show
    authorize! :show, user

    respond_with(user)
  end

  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "User Update"
  ##~ op.description = "Updates the user of an account. You can update any field, not only those in the form of the ActiveDocs but all the fields that belong to the User object. Remember that you can define custom fields on your Admin Portal."
  ##~ op.group = "user"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_user_id_by_id
  ##~ op.parameters.add :name => "username", :description => "Username of the user.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "email", :description => "Email of the user.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "password", :description => "Password of the user.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add @parameter_extra
  #
  def update
    authorize! :update, user

    user.update_with_flattened_attributes(flat_params)

    respond_with(user)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/users/{id}.xml"
  ##~ e.responseClass = "user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "User Delete"
  ##~ op.description = "Deletes a user of an account. The last user can't be deleted"
  ##~ op.group = "user"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_user_id_by_id
  #
  def destroy
    authorize! :destroy, user

    user.destroy

    respond_with(user)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/users/{id}/member.xml"
  ##~ e.responseClass = "user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "User Change Role to Member"
  ##~ op.description = "Changes the role of the user to member."
  ##~ op.group = "user"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_user_id_by_id
  #
  def member
    authorize! :update_role, user

    user.make_member

    respond_with(user)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/users/{id}/admin.xml"
  ##~ e.responseClass = "user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "User change Role to Admin"
  ##~ op.description = "Changes the role of the user to admin."
  ##~ op.group = "user"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_user_id_by_id
  #
  def admin
    authorize! :update_role, user

    user.make_admin

    respond_with(user)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/users/{id}/suspend.xml"
  ##~ e.responseClass = "user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "User Suspend"
  ##~ op.description = "Changes the state of the user to suspended. A suspended user cannot sign-in."
  ##~ op.group = "user"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_user_id_by_id
  #
  #
  def suspend
    authorize! :suspend, user

    user.suspend!

    respond_with(user)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/users/{id}/unsuspend.xml"
  ##~ e.responseClass = "user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "User Unsuspend"
  ##~ op.description = "Change the state of the user back to active."
  ##~ op.group = "user"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_user_id_by_id
  #
  def unsuspend
    authorize! :unsuspend, user

    user.unsuspend

    respond_with(user)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/users/{id}/activate.xml"
  ##~ e.responseClass = "user"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "User Activate"
  ##~ op.description = "Activate the user of an account. A user is created in the pending state and needs to be activated before he/she is able to sign-in."
  ##~ op.group = "user"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_user_id_by_id
  #
  def activate
    authorize! :update, user

    user.activate! unless user.active?

    respond_with(user)
  end

  protected

  def authorize!(*args)
    current_user ? super : logged_in?
  end

  def new_user
    @new_user ||= buyer.users.new
  end

  def users
    @users ||= begin
      conditions = params.slice(:state, :role)
      buyer.users.where(conditions)
    end
  end

  def user
    @user ||= buyer.users.find(params[:id])
  end

end
