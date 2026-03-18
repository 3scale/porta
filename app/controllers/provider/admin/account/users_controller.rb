# frozen_string_literal: true

class Provider::Admin::Account::UsersController < Provider::Admin::Account::BaseController
  before_action :load_services, only: %i[edit update]
  before_action :load_user, only: %i[edit update destroy]

  authorize_resource

  activate_menu :account, :users, :listing

  helper_method :presenter

  attr_reader :presenter

  def index
    users = current_account.users.but_impersonation_admin
    @presenter = Provider::Admin::Account::UsersIndexPresenter.new(current_user: current_user,
                                                                   users: users,
                                                                   params: params)
  end

  def edit; end

  def update
    @user.validate_fields!

    @user.assign_attributes(user_params)
    @user.role = user_params.fetch(:role, @user.role)

    if @user.save
      redirect_to provider_admin_account_users_path, success: t('.success')
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      redirect_to provider_admin_account_users_path, success: t('.success')
    else
      redirect_to provider_admin_account_users_path, danger: t('.error')
    end
  end

  private

  def load_services
    @services ||= current_account.accessible_services
  end

  def load_user
    @user = users.find(params[:id])
  end

  def users
    @users ||= current_account.users
  end

  def user_params
    allowed_attrs = @user.defined_builtin_fields.map(&:name) + @user.special_fields

    if can?(:update_role, @user)
      allowed_attrs += [:role, { member_permission_ids: [] }]
      allowed_attrs += [:member_permission_service_ids, { member_permission_service_ids: [] }] if current_account.provider_can_use?(:service_permissions)
    end

    params.require(:user).permit(*allowed_attrs, extra_fields: @user.defined_extra_fields_names)
  end
end
