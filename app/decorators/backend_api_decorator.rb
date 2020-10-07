# frozen_string_literal: true

class BackendApiDecorator < ApplicationDecorator

  self.include_root_in_json = false

  def api_selector_api_link
    h.provider_admin_backend_api_path(object)
  end

  private

  def backend_api?
    true
  end

  # TODO: add missing links
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
