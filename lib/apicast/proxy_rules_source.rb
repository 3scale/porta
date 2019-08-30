# frozen_string_literal: true

module Apicast
  class ProxyRulesSource
    attr_reader :proxy

    delegate :backend_api_configs, to: :proxy

    def initialize(proxy)
      @proxy = proxy
    end

    def to_hash
      api_proxy_rules = proxy.proxy_rules

      api_proxy_rules += backend_api_configs.flat_map do |config|
        config.backend_api.proxy_rules.decorate(context: { backend_api_path: config.path })
      end

      api_proxy_rules.as_json(root: false)
    end
  end
end
