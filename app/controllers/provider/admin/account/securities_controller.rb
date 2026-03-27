# frozen_string_literal: true

class Provider::Admin::Account::SecuritiesController < Provider::Admin::BaseController
  activate_menu! :account, :integrate, :security

  before_action :find_account

  def edit
    @permission_policy_admin_portal = find_or_build_setting('AccountSetting::PermissionsPolicyHeaderAdmin')
  end

  def update
    @permission_policy_admin_portal = find_or_build_setting('AccountSetting::PermissionsPolicyHeaderAdmin')
    
    if @permission_policy_admin_portal.update(setting_params)
      redirect_to edit_provider_admin_account_security_path, success: t('.success')
    else
      flash.now[:danger] = t('.error')
      render :edit
    end
  end

  private

  def find_account
    @account = current_account
  end

  def find_or_build_setting(type)
    @account.account_settings.find_or_initialize_by(type: type)
  end

  def setting_params
    params.require(:account_setting).permit(:value)
  end
end
