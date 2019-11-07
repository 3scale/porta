# frozen_string_literal: true

class ProxyRuleDecorator < ApplicationDecorator
  self.include_root_in_json = false

  def pattern
    parts = [backend_api_path, object.pattern].compact
    '/' + parts.map { |part| StringUtils::StripSlash.strip_slash(part).presence }.compact.join('/')
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
