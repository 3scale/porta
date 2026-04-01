# frozen_string_literal: true

class Provider::Admin::SecuritiesController < Provider::Admin::BaseController

  activate_menu! :account, :integrate, :security

  before_action :find_settings
  before_action :find_permission_policy_setting

  def edit; end

  def update
    # Extract permission policy params before updating settings
    policy_params = params[:settings]&.delete(:account_setting_attributes)

    settings_updated = @settings.update(params[:settings])
    policy_updated = update_permission_policy_setting(policy_params)

    if settings_updated && policy_updated
      redirect_to edit_provider_admin_security_url, success: t('.success')
    else
      flash.now[:danger] = t('.error')
      render :action => 'edit'
    end
  end

  private

  def find_settings
    @settings = current_account.settings
  end

  def find_permission_policy_setting
    @permission_policy_admin_portal = current_account.account_settings.find_or_initialize_by(
      type: 'AccountSetting::PermissionsPolicyHeaderAdmin'
    )
  end

  def update_permission_policy_setting(policy_params)
    return true unless policy_params

    @permission_policy_admin_portal.assign_attributes(policy_params.permit(:value))
    @permission_policy_admin_portal.save
  end
end
