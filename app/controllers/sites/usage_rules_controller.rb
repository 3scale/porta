class Sites::UsageRulesController < Sites::BaseController
  provider_required
  before_action :find_settings
  activate_menu :audience, :accounts, :usage_rules

  def edit
  end

  def update
    saved = AccountSetting.transaction do
      (@settings.update(settings_params) & update_approval_required) || raise(ActiveRecord::Rollback)
    end

    if saved
      redirect_back_or_to admin_site_settings_url, success: t('.success')
    else
      flash.now[:danger] = t('.error')
      render :edit
    end
  end

  private

  def find_settings
    @settings = current_account.settings
  end

  ALLOWED_PARAMS = %i[
    useraccountarea_enabled signups_enabled public_search
    account_plans_ui_visible change_account_plan_permission
    service_plans_ui_visible change_service_plan_permission
    hide_service cas_server_url
  ].freeze

  def settings_params
    params.require(:settings).permit(*ALLOWED_PARAMS)
  end

  def update_approval_required
    approval = params.require(:settings).permit(:account_approval_required)
    return true unless approval.key?(:account_approval_required) && @settings.approval_required_editable?

    plan = @settings.default_account_plan
    plan.approval_required = approval[:account_approval_required]
    plan.validate
    errors = plan.errors[:approval_required]
    errors.each { @settings.errors.add(:account_approval_required, _1) }
    # Like master's update_attribute, invalid unrelated plan attributes don't block this change
    errors.empty? && plan.save!(validate: false)
  end
end
