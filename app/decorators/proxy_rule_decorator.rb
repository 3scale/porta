# frozen_string_literal: true

class ProxyRuleDecorator < ApplicationDecorator

  self.include_root_in_json = false

  def pattern
    pattern_value = object.pattern
    backend_api_path ? File.join('/', backend_api_path, pattern_value) : pattern_value
  end

  private

  def delegatable?(method)
    return false if method.to_sym == :pattern
    object.respond_to?(method)
  end

  def backend_api_path
    context[:backend_api_path]
  end
end
