class Stats::DashboardsController < Stats::ServiceBaseController
  sublayout :stats, :only => [:show]

  def show
    redirect_to admin_service_stats_usage_path(@service)
  end
end
