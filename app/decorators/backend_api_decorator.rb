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

  def products_table_data
    ServiceDecorator.decorate_collection(services.accessible.sort_by(&:name))
                    .map(&:table_data)
                    .to_json
  end

  def table_data
    {
      name: name,
      description: private_endpoint,
      href: link
    }
  end

  alias link api_selector_api_link

  def products_count
    object.backend_api_configs.size
  end

  private

  def backend_api?
    true
  end
end
