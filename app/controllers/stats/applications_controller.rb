class Stats::ApplicationsController < Stats::BaseController
  before_action :find_cinstance
  before_action :find_service
  before_action :find_buyer_account

  activate_menu :serviceadmin, :applications, :listing
  sublayout 'api/service'

  def show
    @metrics = @service.metrics.top_level
    @methods = @service.method_metrics

    respond_to do |format|
      format.html { render :show }
      format.json { render json: metrics_with_methods }
    end
  end

  private

  def find_cinstance
    @cinstance = current_account.provided_cinstances.find params[:id]
  end

  def find_service
    @service = @cinstance.service

    authorize!(:show, @cinstance.service)
  end

  def find_buyer_account
    @account = @cinstance.user_account
  end

  # TODO: render deprecated metric.service_id even when attribute is not set
  # We can consider whether we can change this API as it is not intended for
  # public use, see 0886ce743ab57c (#2599)
  def metrics_with_methods
    {metrics: @metrics, methods: @methods}
  end

  def activate_submenu
    activate_menu submenu: current_account.multiservice? ? :services : @service.name
  end
end
