class ApicastV2DeploymentService
  attr_reader :proxy, :source

  def initialize(proxy)
    @proxy = proxy
    @source = Apicast::ProxySource.new(proxy)
  end

  def call(environment:, user: User.current)
    default_params = { proxy: proxy, user: user, environment: environment }
    latest_config  = ProxyConfig.where(default_params).newest_first.first
    new_config     = ProxyConfig.new(default_params.merge(content: source.to_json))

    if new_config.differs_from?(latest_config)
      new_config.save && new_config
    else
      latest_config
    end
  end
end
