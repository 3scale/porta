# frozen_string_literal: true

class BackendApiDecorator < ApplicationDecorator

  self.include_root_in_json = false

  def api_selector_api_link
    h.provider_admin_backend_api_path(object)
  end

  def as_json(options = {})
    hash = super(options)
    parse_api hash
  end

  private

  def backend_api?
    true
  end

  # TODO: add missing links
  def links
    [
      { name: 'Edit', path: h.edit_provider_admin_backend_api_path(@object) },
      { name: 'Overview', path: '' },
      { name: 'Analytics', path: '' },
      { name: 'Methods & Metrics', path: '' },
      { name: 'Mapping Rules', path: '' },
    ]
  end

  def products_count
    object.services.size
  end
end
