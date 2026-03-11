class Provider::Admin::User::PersonalDetailsController < Provider::Admin::User::BaseController
  before_action :current_password_verification, only: :update
  activate_menu :account, :personal, :personal_details

  def edit; end

  def update
    if current_user.update(permitted_user_params)
      if current_user.just_changed_password?
        current_user.kill_user_sessions(user_session)
      end
      redirect_to redirect_path, success: t('.success')
    else
      render action: 'edit'
    end
  end

  private

  def redirect_path
    if params[:origin] == 'users'
      provider_admin_account_users_path
    else
      edit_provider_admin_user_personal_details_path
    end
  end

  def user_params
    @user_params ||= params.require(:user)
  end

  def permitted_user_params
    @permitted_user_params ||= begin
      allowed_attrs = current_user.defined_builtin_fields_names | %i(password)
      user_params.permit(*allowed_attrs, extra_fields: current_user.defined_extra_fields_names)
    end
  end

  def current_password_verification
    return true unless current_user.using_password?

    unless current_user.authenticated?(user_params[:current_password])
      flash.now[:danger] = t('.wrong')
      AuditLogService.call("User tried to change password, but failed due to incorrect current password: #{current_user.id}/#{current_user.username}") if user_params[:password].present?
      render(action: :edit)
    end
  end
end
