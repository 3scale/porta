# frozen_string_literal: true

class Sites::SecuritiesController < Sites::BaseController
  activate_menu :audience, :cms, :security

  ACCOUNT_SETTING_TYPES = %w[AccountSetting::PermissionsPolicyHeaderDeveloper].freeze

  before_action :find_settings
  before_action :find_account_settings

  def edit
  end

  def update
    # TODO: Once Settings is fully migrated to AccountSettings, handle all settings uniformly
    # instead of separating legacy Settings model updates from AccountSettings updates
    settings_updated = @settings.update(settings_params)
    account_settings_updated = update_account_settings

    if settings_updated && account_settings_updated
      redirect_to edit_admin_site_security_url, success: t('.success')
    else
      flash.now[:danger] = t('.error')
      render :action => 'edit'
    end
  end

  private

  def settings_params
    params.permit(settings: [:spam_protection_level]).fetch(:settings, {})
  end

  def find_settings
    @settings = current_account.settings
  end

  def find_account_settings
    @account_settings = ACCOUNT_SETTING_TYPES.map do |type|
      current_account.account_settings.find_or_initialize_by(type: type)
    end
  end

  def update_account_settings
    @account_settings.all? do |setting|
      value = params.dig(:settings, setting.setting_name)

      if value.nil?
        setting.persisted? ? setting.destroy : true
      else
        setting.value = value
        setting.save
      end
    end
  end
end
