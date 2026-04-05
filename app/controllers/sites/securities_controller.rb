class Sites::SecuritiesController < Sites::BaseController
  activate_menu :audience, :cms, :security

  before_action :find_settings
  before_action :find_permissions_policy_setting

  def edit
  end

  def update
    settings_params = params.fetch(:settings, {}).dup
    setting_name = @permissions_policy_developer_portal.setting_name
    permissions_policy_value = settings_params.delete(setting_name)

    # TODO: Once Settings is fully migrated to AccountSettings, handle all settings uniformly
    # instead of separating legacy Settings model updates from AccountSettings updates
    settings_updated = @settings.update(settings_params.permit(:spam_protection_level))
    policy_updated = update_permissions_policy_setting(permissions_policy_value)

    if settings_updated && policy_updated
      redirect_to edit_admin_site_security_url, success: t('.success')
    else
      flash.now[:danger] = t('.error')
      render :action => 'edit'
    end
  end

  private

  def find_settings
    @settings = current_account.settings
  end

  def find_permissions_policy_setting
    @permissions_policy_developer_portal = current_account.account_settings.find_or_initialize_by(
      type: 'AccountSetting::PermissionsPolicyHeaderDeveloper'
    )
  end

  def update_permissions_policy_setting(permissions_policy_value)
    return true if permissions_policy_value.nil?

    @permissions_policy_developer_portal.value = permissions_policy_value
    @permissions_policy_developer_portal.save
  end
end
