# frozen_string_literal: true

class ProxyRuleDecorator < ApplicationDecorator
  self.include_root_in_json = false

  def pattern
    path_joined_parts = ['/', backend_api_path, object.pattern].join('/')
    path_without_duplicated_slashes = path_joined_parts.gsub(%r{\/{2,}}, '/')
    path_without_duplicated_slashes.chomp('/').presence || '/'
  end

  def metric_system_name
    object.metric.attributes['system_name']
  end

  private

  def delegatable?(method)
    return false if self.class.instance_methods(false).include?(method.to_sym)
    object.respond_to?(method)
  end

  def backend_api_path
    context[:backend_api_path]
  end
end
