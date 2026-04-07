# frozen_string_literal: true

class Provider::Admin::SecuritiesController < Provider::Admin::BaseController

  activate_menu! :account, :integrate, :security

  before_action :find_settings
  before_action :find_permissions_policy_setting

  def edit; end

  def update
    # TODO: Once Settings is fully migrated to AccountSettings, handle all settings uniformly
    # instead of separating legacy Settings model updates from AccountSettings updates
    settings_updated = @settings.update(settings_params)
    policy_updated = update_permissions_policy_setting

    if settings_updated && policy_updated
      redirect_to edit_provider_admin_security_url, success: t('.success')
    else
      flash.now[:danger] = t('.error')
      render :action => 'edit'
    end
  end

  private

  def settings_params
    params.permit(settings: [:admin_bot_protection_level]).fetch(:settings, {})
  end

  def find_settings
    @settings = current_account.settings
  end

  def find_permissions_policy_setting
    @permissions_policy = current_account.account_settings.find_or_initialize_by(
      type: 'AccountSetting::PermissionsPolicyHeaderAdmin'
    )
  end

  def update_permissions_policy_setting
    value = params.dig(:settings, @permissions_policy.setting_name)
    return true if value.nil?

    @permissions_policy.value = value
    @permissions_policy.save
  end
end
