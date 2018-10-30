class Stats::DaysController < Stats::ServiceBaseController

  activate_menu :serviceadmin, :monitoring, :daily_averages

  def index
    @data = ::Stats::Deprecated.average_usage_by_weekdays_for_all_metrics(@service)
    render :index
  end

  def show
    @day = params[:id]
    @metric = @service.metrics.find(params[:metric_id])
    @data = ::Stats::Deprecated.usage_in_day(@service, :day => @day, :metric => @metric)
  end

end
