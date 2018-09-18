class Stats::DashboardsController < Stats::ServiceBaseController

  skip_before_action :find_service, :only => [:index]

  sublayout :stats, :only => [:show]

  def index
    @services = collection.includes(:metrics)

    if @services.size == 1
      return redirect_to admin_service_stats_usage_path(@services.first)
    end
  end

  def show
    redirect_to admin_service_stats_usage_path(@service)
  end
end
