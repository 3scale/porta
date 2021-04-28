# frozen_string_literal: true

class BackendApiDecorator < ApplicationDecorator

  self.include_root_in_json = false

  def api_selector_api_link
    h.provider_admin_backend_api_path(object)
  end

  def add_backend_usage_backends_data
    {
      id: id,
      name: name,
      privateEndpoint: private_endpoint,
      updatedAt: updated_at
    }
  end

  def products_used_table_data
    ServiceDecorator.decorate_collection(services.accessible.order(:name))
                    .map(&:used_by_backend_table_data)
                    .to_json
  end

  alias link api_selector_api_link

  private

  def backend_api?
    true
  end

  def links
    [
      { name: 'Edit', path: h.edit_provider_admin_backend_api_path(object) },
      { name: 'Overview', path: h.provider_admin_backend_api_path(object) },
      { name: 'Analytics', path: h.provider_admin_backend_api_stats_usage_path(object) },
      { name: 'Methods & Metrics', path: h.provider_admin_backend_api_metrics_path(object) },
      { name: 'Mapping Rules', path: h.provider_admin_backend_api_mapping_rules_path(object) },
    ]
  end

  def products_count
    object.services.size
  end
end
