class DeveloperPortal::Admin::Account::UsersController < ::DeveloperPortal::BaseController
  before_action :ensure_buyer_domain
  before_action :load_user, only: [:edit, :update, :destroy]

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

    if update_resource(@user, [user_params])
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

  def update_resource(user, attributes)
    attributes.each do |attrs|
      user.attributes = filter_readonly_params(attrs, User)
      user.role = attrs[:role] if can? :update_role, user
    end
    user.save
  end

  def user_params
    params.fetch(:user, {}).permit(:username, :email, :password, :password_confirmation, :role)
  end
end
