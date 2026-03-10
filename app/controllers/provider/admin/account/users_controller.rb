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

  def edit
    # Renders edit view
  end

  def update
    @user.validate_fields!

    if update_resource(@user, user_params)
      redirect_to provider_admin_account_users_path, success: t('.success')
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t('.success')
      redirect_to provider_admin_account_users_path
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

  def update_resource(user, attributes)
    # After the rails 5.1 upgrade, attributes comes as ActionController::Parameters except when they are empty
    attributes = attributes.permit!.to_h unless attributes.is_a?(Hash)

    protected_attributes = attributes.extract!(*User::Permissions::ATTRIBUTES)

    unless current_account.provider_can_use?(:service_permissions)
      protected_attributes.except!(:member_permission_service_ids)
    end

    user.class.transaction do
      user.assign_attributes(attributes)
      user.assign_attributes(protected_attributes, without_protection: can?(:update_role, user))

      user.save
    end
  end

  def user_params
    params.require(:user).permit(
      *@user.required_fields, *@user.optional_fields, *@user.special_fields,
      :role, member_permission_ids: [], member_permission_service_ids: [],
      extra_fields: {}
    )
  end
end
