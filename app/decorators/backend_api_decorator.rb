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
end
