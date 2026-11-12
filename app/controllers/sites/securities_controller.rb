# frozen_string_literal: true

class Sites::SecuritiesController < Sites::BaseController
  activate_menu :audience, :cms, :security

  HEADER_SETTINGS = %i[permissions_policy_header_developer csp_header_developer csp_report_only_header_developer].freeze

  before_action :find_settings

  def edit
  end

  def update
    if @settings.update(settings_params)
      redirect_to edit_admin_site_security_url, success: t('.success')
    else
      flash.now[:danger] = t('.error')
      render :action => 'edit'
    end
  end

  private

  # An omitted header means its "use custom value" checkbox was unchecked, so the stored value is cleared.
  def settings_params
    permitted = params.permit(settings: [:spam_protection_level, *HEADER_SETTINGS]).fetch(:settings, {})
    HEADER_SETTINGS.index_with(nil).merge(permitted.to_h.symbolize_keys)
  end

  def find_settings
    @settings = current_account.settings
    @header_settings = HEADER_SETTINGS
  end
end
