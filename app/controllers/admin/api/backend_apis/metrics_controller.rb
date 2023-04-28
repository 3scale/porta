# frozen_string_literal: true

class Admin::Api::BackendApis::MetricsController < Admin::Api::BackendApis::BaseController
  include MetricParams

  wrap_parameters Metric
  representer Metric

  # Backend Metric List
  # GET /admin/api/backend_apis/{backend_api_id}/metrics.json
  def index
    respond_with(metrics_collection.order(:id).paginate(pagination_params))
  end

  # Backend Metric Read
  # GET /admin/api/backend_apis/{backend_api_id}/metrics/{id}.json
  def show
    respond_with(metric)
  end

  # Backend Metric Create
  # POST /admin/api/backend_apis/{backend_api_id}/metrics.json
  def create
    metric = metrics_collection.create(create_params)
    respond_with(metric)
  end

  # Backend Metric Update
  # PUT /admin/api/backend_apis/{backend_api_id}/metrics/{id}.json
  def update
    metric.update(update_params)
    respond_with(metric)
  end

  # Backend Metric Delete
  # DELETE /admin/api/backend_apis/{backend_api_id}/metrics/{id}.json
  def destroy
    metric.destroy
    respond_with(metric)
  end

  private

  def metric
    @metric ||= metrics_collection.find(params[:id])
  end

  def metrics_collection
    @metrics_collection ||= backend_api.metrics
  end
end
