# frozen_string_literal: true

class Admin::Api::BackendApis::MetricMethodsController < Admin::Api::BackendApis::MetricsController
  representer Method

  # Backend Method List
  # GET /admin/api/backend_apis/{backend_api_id}/metrics/{metric_id}/methods.json

  # Backend Method Create
  # POST /admin/api/backend_apis/{backend_api_id}/metrics/{metric_id}/methods.json

  # Backend Method Read
  # GET /admin/api/backend_apis/{backend_api_id}/metrics/{metric_id}/methods/{id}.json

  # Backend Method Update
  # PUT /admin/api/backend_apis/{backend_api_id}/metrics/{metric_id}/methods/{id}.json

  # Backend Method Delete
  # DELETE /admin/api/backend_apis/{backend_api_id}/metrics/{metric_id}/methods/{id}.json

  private

  def metrics_collection
    @metrics_collection ||= backend_api.metrics.find(params[:metric_id]).children
  end
end
