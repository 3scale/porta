class Provider::Admin::User::PersonalDetailsController < Provider::Admin::User::BaseController
  before_action :current_password_verification, only: :update
  activate_menu! submenu: :personal_details

  def edit; end

  def update
    if current_user.update_attributes(user_params)
      if current_user.just_changed_password?
        current_user.kill_user_sessions(user_session)
      end
      redirect_to redirect_path, notice: 'User was successfully updated.'
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
    params.require(:user)
  end

  def current_password_verification
    return true unless current_user.using_password?

    unless current_user.authenticated?(user_params[:current_password])
      flash.now[:error] = 'Current password is incorrect.'
      render(action: :edit)
    end
  end
end
