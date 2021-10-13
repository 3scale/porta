# frozen_string_literal: true

class BackendApiPresenter < SimpleDelegator
  include System::UrlHelpers.system_url_helpers

  def index_data
    {
      id: id,
      name: name,
      systemName: system_name,
      updatedAt: updated_at.to_s(:long),
      privateEndpoint: private_endpoint,
      links: links,
      productsCount: decorate.products_count
    }
  end

  def dashboard_widget_data
    {
      id: id,
      name: name,
      updated_at: updated_at.to_s(:long),
      link: self.decorate.link,
      links: links
    }
  end

  protected

  def links
    [
      { name: 'Edit', path: edit_provider_admin_backend_api_path(self) },
      { name: 'Overview', path: provider_admin_backend_api_path(self) },
      { name: 'Analytics', path: provider_admin_backend_api_stats_usage_path(self) },
      { name: 'Methods and Metrics', path: provider_admin_backend_api_metrics_path(self) },
      { name: 'Mapping Rules', path: provider_admin_backend_api_mapping_rules_path(self) },
    ]
  end
end
