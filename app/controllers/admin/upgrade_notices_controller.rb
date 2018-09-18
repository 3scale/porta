class Admin::UpgradeNoticesController < FrontendController

  before_action :find_switch
  helper_method :active_upgrade_notice

  activate_menu :upgrade_notices

  def show
    @plan = current_account.bought_plan
    @new_plan = current_account.first_plan_with_switch(@switch)
    render 'feature_not_available'
  end

  private

  SWITCH_TO_MENU = {
      :finance => :finance,
      :multiple_applications => :applications
  }.freeze

  def find_switch
    @switch = params.fetch(:id)

    unless current_account.settings.switches.with_indifferent_access.has_key?(@switch)
      raise ActiveRecord::RecordNotFound, "Switch '#{@switch}' is invalid."
    end
  end

  def active_upgrade_notice
    SWITCH_TO_MENU[@switch]
  end

end
