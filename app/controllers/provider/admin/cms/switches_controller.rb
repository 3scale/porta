class Provider::Admin::CMS::SwitchesController < Provider::Admin::CMS::BaseController

  activate_menu :cms, :features_visibility
  sublayout nil

  before_action :find_switch, only: [ :update, :destroy ]

  def index
    @allowed, @denied = current_account.hideable_switches.partition { |switch,status| status.allowed? }

    @allowed = @allowed.select { |switch, plan| plan.settings.visible_ui?(switch) }
  end

  def update
    @switch.show!
  end

  def destroy
    @switch.hide!
    render action: :update
  end

  private

  def find_switch
    # https://github.com/3scale/system/issues/3162
    @switch = current_account.hideable_switches[params[:id]]
    raise ActiveRecord::RecordNotFound unless @switch
  end
end
