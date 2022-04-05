class Stats::UsageController < Stats::ServiceBaseController
  before_action :find_service, :only => [:index_data, :top_applications, :hours, :index]
  before_action :find_metric, :only => :index_data

  activate_menu :serviceadmin, :monitoring, :usage

  liquify if: :buyer_domain?

  def index
    @methods, @metrics = @service.all_metrics.partition(&:method_metric?)

    if ['api_sandbox_traffic', 'apicast_gateway_deployed'].include? current_account.go_live_state.recent
      done_step(:verify_api_sandbox_traffic)
    end

    respond_to do |format|
      format.html { render :index }
      format.json { render json: metrics_with_methods }
    end
  end

  def top_applications
    activate_menu :serviceadmin, :monitoring, :top_applications
    @methods, @metrics = @service.all_metrics.partition(&:method_metric?)

    respond_to do |format|
      format.html { render :top_applications }
      format.json { render json: metrics_with_methods }
    end
  end

  def hours
    activate_menu :serviceadmin, :monitoring, :hourly
    timezone = params[:timezone] || @current_user.account.timezone
    @data = ::Stats::Deprecated.average_usage_by_hours_for_all_metrics(@service, :timezone => timezone)
    render :hours
  end

  protected

  def find_metric
    @metric = @service.metrics.find(params[:metric_id])
  end

  # TODO: render deprecated metric.service_id even when attribute is not set
  # We can consider whether we can change this API as it is not intended for
  # public use, see 0886ce743ab57c
  def metrics_with_methods
    {metrics: @metrics, methods: @methods}
  end
end
