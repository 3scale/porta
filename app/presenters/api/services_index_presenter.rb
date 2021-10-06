# frozen_string_literal: true

class Api::ServicesIndexPresenter
  include System::UrlHelpers.system_url_helpers

  def initialize(current_user:, params: {})
    @current_user = current_user
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @search = ThreeScale::Search.new(params[:search] || params)
  end

  attr_reader :current_user, :pagination_params, :search

  def data
    {
      'new-product-path': new_admin_service_path,
      products: products_data.to_json,
      'products-count': page_products.total_entries.to_json
    }
  end

  def dashboard_widget_data
    {
      products: dashboard_widget_products,
      newProductPath: new_admin_service_path,
      productsPath: admin_services_path
    }
  end

  protected

  def scoped_products
    @scoped_products ||= current_user.accessible_services
                                     .order(updated_at: :desc)
                                     .scope_search(search)
  end

  def page_products
    @page_products ||= scoped_products.paginate(pagination_params)
  end

  def products_data
    page_products.map do |product|
      {
        id: product.id,
        name: product.name,
        systemName: product.system_name,
        updatedAt: product.updated_at,
        links: links(product),
        appsCount: product.cinstances.size,
        backendsCount: product.backend_api_configs.size,
        unreadAlertsCount: product.decorate.unread_alerts_count
      }
    end
  end

  def dashboard_widget_products
    current_user.accessible_services
                .order(updated_at: :desc)
                .take(5)
                .map do |product|
                  {
                    id: product.id,
                    name: product.name,
                    updated_at: product.updated_at,
                    link: product.decorate.link,
                    links: links(product)
                  }
                end
  end

  def links(product)
    [
      { name: 'Edit', path: edit_admin_service_path(product) },
      { name: 'Overview', path: admin_service_path(product) },
      { name: 'Analytics', path: admin_service_stats_usage_path(product) },
      { name: 'Applications', path: admin_service_applications_path(product) },
      { name: 'ActiveDocs', path: admin_service_api_docs_path(product) },
      { name: 'Integration', path: admin_service_integration_path(product) },
    ]
  end
end
