class Admin::Api::UsersController < Admin::Api::BaseController
  representer User

  before_action :can_create, only: :create

  # User List (provider account)
  # GET /admin/api/users.xml
  def index
    authorize! :manage, :multiple_users

    respond_with(users)
  end

  # User Create (provider account)
  # POST /admin/api/users.xml
  def create
    user = new_user

    authorize! :create, user

    user.unflattened_attributes = flat_params
    user.signup_type = :api

    user.save

    respond_with(user)
  end

  # User Read (provider account)
  # GET /admin/api/users/{id}.xml
  def show
    authorize! :show, user

    respond_with(user)
  end

  # User Update (provider account)
  # PUT /admin/api/users/{id}.xml
  def update
    authorize! :update, user

    user.update_with_flattened_attributes(flat_params, as: current_user.try(:role))

    respond_with(user)
  end

  # User Delete (provider account)
  # DELETE /admin/api/users/{id}.xml
  def destroy
    authorize! :destroy, user

    user.destroy

    respond_with(user)
  end

  # User Change Role to Member (provider account)
  # PUT /admin/api/users/{id}/member.xml
  def member
    authorize! :update_role, user

    user.make_member

    respond_with(user)
  end

  # User Change Role to Admin (provider account)
  # PUT /admin/api/users/{id}/admin.xml
  def admin
    authorize! :update_role, user

    user.make_admin

    respond_with(user)
  end

  # User Suspend (provider account)
  # PUT /admin/api/users/{id}/suspend.xml
  def suspend
    authorize! :suspend, user

    user.suspend!

    respond_with(user)
  end

  # User Unsuspend (provider account)
  # PUT /admin/api/users/{id}/unsuspend.xml
  def unsuspend
    authorize! :unsuspend, user

    user.unsuspend

    respond_with(user)
  end

  # User Activate (provider account)
  # PUT /admin/api/users/{id}/activate.xml
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

  private

  def flat_params
    super.except(:id)
  end
end
