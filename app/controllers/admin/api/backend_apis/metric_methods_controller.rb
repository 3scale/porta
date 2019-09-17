# frozen_string_literal: true

class Admin::Api::BackendApis::MetricMethodsController < Admin::Api::BackendApis::MetricsController
  representer Method

  private

  def metrics_collection
    @metrics_collection ||= backend_api.metrics.find(params[:metric_id]).children
  end
end
