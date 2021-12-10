# frozen_string_literal: true

class Api::MetricsIndexPresenter
  include System::UrlHelpers.system_url_helpers

  delegate :top_level_metrics, :method_metrics, :metrics, to: :service

  def initialize(service:, params: {})
    @service = service
    @tab = params[:tab]
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @search = ThreeScale::Search.new(params[:search] || params)
  end

  attr_reader :service, :pagination_params, :tab, :search

  def index_data
    {
      'application-plans-path': admin_service_application_plans_path(service),
      'add-mapping-rule-path': new_admin_service_proxy_rule_path(service),
      'create-metric-path': create_path,
      'mapping-rules-path': admin_service_proxy_rules_path(service),
      'metrics': page_metrics.to_json,
      'metrics-count': collection.total_entries
    }
  end

  def collection
    @collection ||= raw_collection.scope_search(search)
                                  .paginate(pagination_params)
  end

  def create_path
    metrics? ? new_admin_service_metric_path(service) : new_admin_service_metric_child_path(service, metrics.hits)
  end

  protected

  def raw_collection
    @raw_collection ||= metrics? ? top_level_metrics : method_metrics
  end

  def metrics?
    tab == 'metrics'
  end

  def page_metrics
    collection.map { |m| metric_table_data(m) }
  end

  def metric_table_data(metric)
    {
      id: metric.id,
      name: metric.friendly_name,
      systemName: metric.system_name,
      updatedAt: metric.updated_at,
      path: edit_admin_service_metric_path(metric.owner, metric),
      unit: metric.unit,
      description: metric.description,
      mapped: metric.decorate.mapped?
    }
  end
end
