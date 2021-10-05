# frozen_string_literal: true

class Provider::Admin::BackendApis::MetricsIndexPresenter
  include System::UrlHelpers.system_url_helpers

  delegate :top_level_metrics, :method_metrics, :metrics, to: :backend_api

  def initialize(backend_api:, params: {})
    @backend_api = backend_api
    @tab = params[:tab]
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @search = ThreeScale::Search.new(params[:search] || params)
  end

  attr_reader :backend_api, :pagination_params, :tab, :search

  def index_data
    {
      'create-metric-path': create_path,
      'metrics': page_metrics.to_json,
      'metrics-count': collection.total_entries
    }
  end

  def raw_collection
    @raw_collection ||= metrics? ? top_level_metrics : method_metrics
  end

  def collection
    @collection ||= raw_collection.scope_search(search)
                                  .paginate(pagination_params)
  end

  def create_path
    metrics? ? new_provider_admin_backend_api_metric_path(backend_api) : new_provider_admin_backend_api_metric_child_path(backend_api, metrics.hits)
  end

  protected

  def metrics?
    tab == 'metrics'
  end

  def page_metrics
    collection.map { |m| json_data(m) }
  end

  def json_data(metric)
    {
      id: metric.id,
      name: metric.friendly_name,
      systemName: metric.system_name,
      updatedAt: metric.updated_at,
      path: edit_admin_service_metric_path(metric.owner, metric),
      unit: metric.unit,
      description: metric.description,
      mapped: metric.owner.mapping_rules.map(&:metric).include?(metric)
    }
  end
end
