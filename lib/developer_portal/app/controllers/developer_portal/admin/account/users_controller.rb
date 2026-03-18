class DeveloperPortal::Admin::Account::UsersController < ::DeveloperPortal::BaseController
  before_action :ensure_buyer_domain
  before_action :load_user, only: %i[edit update destroy]

  authorize_resource

  activate_menu :account, :users

  liquify prefix: 'accounts/users'

  def index
    users = Liquid::Drops::User.wrap(collection)
    pagination = Liquid::Drops::Pagination.new(collection, self)
    assign_drops users: users, pagination: pagination
  end

  def edit
    assign_liquid_drops
  end

  def update
    @user.validate_fields!

    @user.attributes = filter_readonly_params(user_params, User)
    @user.role = params.fetch(:user, {}).fetch(:role, @user.role) if can?(:update_role, @user)

    if @user.save
      flash[:notice] = 'User was successfully updated.'
      redirect_to admin_account_users_path
    else
      assign_liquid_drops
      render action: 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_account_users_path
  end

  private

  def load_user
    @user = users.find(params[:id])
  end

  def users
    @users ||= current_account.users
  end

  def collection
    @collection ||= users.paginate(page: params[:page])
  end

  def assign_liquid_drops
    assign_drops user: @user
  end

  def user_params
    params.require(:user).permit(*@user.defined_fields.map(&:name), *@user.special_fields)
  end
end
