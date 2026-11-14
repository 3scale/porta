# frozen_string_literal: true

class Provider::Admin::SecuritiesController < Provider::Admin::BaseController

  activate_menu! :account, :integrate, :security

  HEADER_SETTINGS = %i[permissions_policy_header_admin csp_header_admin csp_report_only_header_admin].freeze

  before_action :find_settings

  def edit; end

  def update
    if @settings.update(settings_params)
      redirect_to edit_provider_admin_security_url, success: t('.success')
    else
      flash.now[:danger] = t('.error')
      render :action => 'edit'
    end
  end

  private

  # An omitted header means its "use custom value" checkbox was unchecked, so the stored value is cleared.
  def settings_params
    permitted = params.fetch(:settings, {}).permit(:admin_bot_protection_level, *HEADER_SETTINGS)
    HEADER_SETTINGS.index_with(nil).merge(permitted.to_h.symbolize_keys)
  end

  def find_settings
    @settings = current_account.settings
    @header_settings = HEADER_SETTINGS
  end
end
