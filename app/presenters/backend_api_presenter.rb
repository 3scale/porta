class BackendApiPresenter
  # FIXME: Passing service here makes no sense. We're only keeping this until we define the Backend API model and move everything to it
  def initialize(service = nil)
    @service = service
  end

  attr_reader :service

  def name
    "#{service.name} Backend API"
  end

  def system_name
    "#{service.system_name}_backend_api"
  end

  def description
    "Backend API of #{service.name}"
  end

  alias_method :to_param, :system_name

  delegate :proxy, to: :service

  def private_url
    proxy.api_backend
  end

  def metrics
    service.top_level_metrics
  end

  def method_metrics
    service.method_metrics
  end

  def proxy_rules
    proxy.proxy_rules
  end

  alias_method :mapping_rules, :proxy_rules

  def services
    [service]
  end
end
