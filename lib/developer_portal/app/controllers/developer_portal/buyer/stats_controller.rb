class DeveloperPortal::Buyer::StatsController < DeveloperPortal::BaseController

  activate_menu :dashboard
  liquify prefix: 'stats'

  def index
    @cinstances = applications

    if applications.present?
      assign_drops metrics: Liquid::Drops::Metric.wrap(metrics),
      methods: Liquid::Drops::Metric.wrap(methods),
      applications: Liquid::Drops::Application.wrap(applications)
    else
      redirect_to admin_applications_path
    end
  end

  def index_data
    render :json => usage_data_json(application, metric)
  end

  def metrics_list
    assign_drops metrics: Liquid::Drops::Metric.wrap(metrics)
    render partial: 'stats/metrics_list'
  end

  def methods_list
    assign_drops methods: Liquid::Drops::Metric.wrap(methods),
    metrics: Liquid::Drops::Metric.wrap(metrics)
    render partial: 'stats/methods_list'
  end

  private

  def applications
    @applications ||= current_account.bought_cinstances.live
  end

  def application
    @cinstance ||= if application_id = params[:id]
                     applications.find(application_id)
                   else
                     applications.first
                   end
  end

  def metrics
    @metrics ||= application.service.metrics.top_level.select do |metric|
      metric.enabled_for_plan?(application.plan) &&
        metric.visible_in_plan?(application.plan)
    end
  end

  def methods
    @methods ||= application.service.method_metrics.select do |method|
      method.enabled_for_plan?(application.plan) &&
        method.visible_in_plan?(application.plan)
    end
  end

  def metric
    @metric ||= application.metrics.find(params[:metric_id])
  end
end
