# frozen_string_literal: true

class Provider::Admin::BackendApis::MetricsController < Provider::Admin::BackendApis::BaseController
  activate_menu :backend_api, :methods_metrics
  sublayout 'api/service'

  def index
    @metrics = @backend_api.metrics.top_level.includes(:proxy_rules)
    @methods = @backend_api.method_metrics.includes(:proxy_rules)
    @hits_metric = @backend_api.metrics.hits

    render template: '/api/metrics/index'
  end

  helper_method :bubbles
  delegate :onboarding, to: :current_account

  def bubbles
    onboarding.persisted? ? onboarding.bubbles : []
  end
end
