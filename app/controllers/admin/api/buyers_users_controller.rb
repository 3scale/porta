class Admin::Api::BuyersUsersController < Admin::Api::BuyersBaseController
  representer User

  # User List
  # GET /admin/api/accounts/{account_id}/users.xml
  def index
    authorize! :manage, :multiple_users

    respond_with(users)
  end

  # User Create
  # POST /admin/api/accounts/{account_id}/users.xml
  def create
    user = new_user

    authorize! :create, user

    user.unflattened_attributes = flat_params
    user.signup_type = :api

    user.save

    respond_with(user)
  end

  # User Read
  # GET /admin/api/accounts/{account_id}/users/{id}.xml
  def show
    authorize! :show, user

    respond_with(user)
  end

  # User Update
  # PUT /admin/api/accounts/{account_id}/users/{id}.xml
  def update
    authorize! :update, user

    user.update_with_flattened_attributes(flat_params)

    respond_with(user)
  end

  # User Delete
  # DELETE /admin/api/accounts/{account_id}/users/{id}.xml
  def destroy
    authorize! :destroy, user

    user.destroy

    respond_with(user)
  end

  # User Change Role to Member
  # PUT /admin/api/accounts/{account_id}/users/{id}/member.xml
  def member
    authorize! :update_role, user

    user.make_member

    respond_with(user)
  end

  # User change Role to Admin
  # PUT /admin/api/accounts/{account_id}/users/{id}/admin.xml
  def admin
    authorize! :update_role, user

    user.make_admin

    respond_with(user)
  end

  # User Suspend
  # PUT /admin/api/accounts/{account_id}/users/{id}/suspend.xml
  def suspend
    authorize! :suspend, user

    user.suspend!

    respond_with(user)
  end

  # User Unsuspend
  # PUT /admin/api/accounts/{account_id}/users/{id}/unsuspend.xml
  def unsuspend
    authorize! :unsuspend, user

    user.unsuspend

    respond_with(user)
  end

  # User Activate
  # PUT /admin/api/accounts/{account_id}/users/{id}/activate.xml
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
