# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  delegate_all

  self.include_root_in_json = true

  def api_selector_api_link
    raise NoMethodError, __method__
  end

  private

  API_KEYS = %w[id name system_name].freeze

  def parse_api(api_hash)
    add_link(add_api_type(api_hash.slice(*API_KEYS)))
  end

  def add_link(api_hash)
    api_hash[:link] = api_selector_api_link if object.id
    api_hash
  end

  def add_api_type(api_hash)
    api_hash[:type] = backend_api? ? 'backend' : 'product'
    api_hash
  end

  def backend_api?
    raise NoMethodError, __method__
  end
end
