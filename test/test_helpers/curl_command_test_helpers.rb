# frozen_string_literal: true

module ConfigBasedCommandTestHelpers
  protected

  SIMPLE_PROXY_CONFIG_PROXY_ATTRS = %w[service_id endpoint sandbox_endpoint auth_app_key auth_app_id auth_user_key credentials_location api_test_path].freeze

  def simple_proxy_config_content
    proxy_attributes = proxy.attributes.slice(*SIMPLE_PROXY_CONFIG_PROXY_ATTRS)
    proxy_attributes[:proxy_rules] = [{ pattern: '/foo' }, { pattern: '/bar' }]
    { proxy: proxy_attributes }
  end

  def create_proxy_config(patch = {})
    proxy_config_content = simple_proxy_config_content.deep_merge(patch)
    FactoryBot.create(:proxy_config, proxy: proxy, content: proxy_config_content.to_json)
  end
end
