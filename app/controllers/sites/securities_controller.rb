class Sites::SecuritiesController < Sites::BaseController
  activate_menu :audience, :cms, :security

  before_action :find_settings
  before_action :find_permission_policy_setting

  def edit
  end

  def update
    settings_params = params[:settings]&.dup || {}
    policy_params = settings_params.delete(:account_setting_attributes)

    # TODO: Once Settings is fully migrated to AccountSettings, handle all settings uniformly
    # instead of separating legacy Settings model updates from AccountSettings updates
    settings_updated = @settings.update(settings_params.permit(:spam_protection_level))
    policy_updated = update_permission_policy_setting(policy_params)

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

  def find_permission_policy_setting
    @permission_policy_developer_portal = current_account.account_settings.find_or_initialize_by(
      type: 'AccountSetting::PermissionsPolicyHeaderDeveloper'
    )
  end

  def update_permission_policy_setting(policy_params)
    return true unless policy_params

    @permission_policy_developer_portal.assign_attributes(policy_params.permit(:value))
    @permission_policy_developer_portal.save
  end
end
