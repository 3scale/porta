class Stats::UsageController < Stats::ServiceBaseController
  before_action :find_service, :only => [:index_data, :top_applications, :hours, :index]
  before_action :find_metric, :only => :index_data

  activate_menu :monitoring

  liquify if: :buyer_domain?

  def index
    @methods = @service.method_metrics
    @metrics = @service.metrics.top_level

    if ['api_sandbox_traffic', 'apicast_gateway_deployed'].include? current_account.go_live_state.recent
      done_step(:verify_api_sandbox_traffic)
    end

    respond_to do |format|
      format.html { render :index }
      format.json { render json: metrics_with_methods }
    end
  end

  def top_applications
    @metrics = @service.metrics.top_level
    @methods = @service.method_metrics

    respond_to do |format|
      format.html { render :top_applications }
      format.json { render json: metrics_with_methods }
    end
  end

  def hours
    timezone = params[:timezone] || @current_user.account.timezone
    @data = ::Stats::Deprecated.average_usage_by_hours_for_all_metrics(@service, :timezone => timezone)
    render :hours
  end

  protected

  def find_metric
    @metric = @service.metrics.find(params[:metric_id])
  end

  def metrics_with_methods
    {metrics: @metrics, methods: @methods}
  end
end
