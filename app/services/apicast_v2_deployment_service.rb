# frozen_string_literal: true

class ApicastV2DeploymentService
  attr_reader :proxy

  def initialize(proxy)
    @proxy = proxy
  end

  def call(environment:, user: User.current)
    default_params = { proxy: proxy, user: user, environment: environment }
    latest_config  = ProxyConfig.where(default_params).newest_first.first
    new_config     = ProxyConfig.new(default_params.merge(content: json_source))

    if new_config.differs_from?(latest_config)
      new_config.save && new_config
    else
      latest_config
    end
  end

  private

  def json_source
    proxy_source = Apicast::ProxySource.new(proxy).to_hash
    proxy_source['proxy']['proxy_rules'] = Apicast::ProxyRulesSource.new(proxy).to_hash
    proxy_source['proxy']['api_backend'] = nil if proxy.with_subpaths?
    proxy_source.to_json
  end
end
