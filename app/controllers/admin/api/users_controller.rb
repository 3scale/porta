class Admin::Api::UsersController < Admin::Api::BaseController
  representer User

  before_action :can_create, only: :create
  before_action :build_new_user, only: %i[create]
  before_action :find_user, except: %i[create index]

  attr_reader :user

  # User List (provider account)
  # GET /admin/api/users.xml
  def index
    authorize! :manage, :multiple_users

    respond_with(users)
  end

  # User Create (provider account)
  # POST /admin/api/users.xml
  def create
    authorize! :create, user

    user.unflattened_attributes = user_params
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

    user.update_with_flattened_attributes(user_params)

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

  def users
    @users ||= begin
      conditions = params.slice(:state, :role)
      current_account.users.but_impersonation_admin.where(conditions)
    end
  end

  def build_new_user
    @user = current_account.users.new
  end

  def find_user
    @user = current_account.users.but_impersonation_admin.find(params[:id])
  end

  def can_create
    head :forbidden unless current_account.can_create_user?
  end

  private

  def flat_params
    super.except(:id)
  end

  def user_params
    @user_params ||= begin
                       allowed_attrs = user.defined_fields_names | %i(password password_confirmation cas_identifier)
                       allowed_attrs |= [member_permission_service_ids: [], member_permission_ids: [], allowed_sections: [], allowed_service_ids: []] if (provider_key.present? || current_user.admin?)
                       # TODO: are these parameters needed?
                       # allowed_attrs |= %i(conditions open_id service_conditions)
                       flat_params.permit(*allowed_attrs)
                     end
  end
end
