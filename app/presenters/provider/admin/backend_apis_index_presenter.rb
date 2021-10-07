# frozen_string_literal: true

class Provider::Admin::BackendApisIndexPresenter
  include System::UrlHelpers.system_url_helpers

  def initialize(current_account:, params: {})
    @current_account = current_account
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @sorting_params = [params[:sort] || 'updated_at', params[:direction] || 'desc']
    @search = ThreeScale::Search.new(params[:search])
  end

  attr_reader :current_account, :pagination_params, :sorting_params, :search

  def data
    {
      'new-backend-path': new_provider_admin_backend_api_path,
      backends: backends_data.to_json,
      'backends-count': page_backend_apis.total_entries.to_json
    }
  end

  def dashboard_widget_data
    {
      backends: dashboard_widget_backends,
      newBackendPath: new_provider_admin_backend_api_path,
      backendsPath: provider_admin_backend_apis_path
    }
  end

  protected

  def scoped_backen_apis
    @scoped_backen_apis ||= current_account.backend_apis
                                           .order_by(*sorting_params)
                                           .scope_search(search)
  end

  def page_backend_apis
    @page_backend_apis ||= scoped_backen_apis.paginate(pagination_params)
  end

  def backends_data
    page_backend_apis.map do |backend_api|
      {
        id: backend_api.id,
        name: backend_api.name,
        systemName: backend_api.system_name,
        updatedAt: backend_api.updated_at,
        privateEndpoint: backend_api.private_endpoint,
        links: links(backend_api),
        productsCount: backend_api.decorate.products_count
      }
    end
  end

  def dashboard_widget_backends
    current_account.backend_apis
                   .order(updated_at: :desc)
                   .take(5)
                   .map do |backend_api|
                     {
                       id: backend_api.id,
                       name: backend_api.name,
                       updated_at: backend_api.updated_at,
                       link: backend_api.decorate.link,
                       links: links(backend_api)
                     }
                   end
  end

  def links(backend_api)
    [
      { name: 'Edit', path: edit_provider_admin_backend_api_path(backend_api) },
      { name: 'Overview', path: provider_admin_backend_api_path(backend_api) },
      { name: 'Analytics', path: provider_admin_backend_api_stats_usage_path(backend_api) },
      { name: 'Methods and Metrics', path: provider_admin_backend_api_metrics_path(backend_api) },
      { name: 'Mapping Rules', path: provider_admin_backend_api_mapping_rules_path(backend_api) },
    ]
  end
end
