module BackendClient
  class Application < Base

    include Utilization

    attr_reader :provider
    attr_reader :cinstance

    http_methods :get, :post, :delete do |method, path, params|
      provider.send method, "/applications/#{id}#{path}",  {:service_id => service_id}.merge(params)
    end

    def initialize(provider, cinstance)
      @provider  = provider
      @cinstance = cinstance
    end

    def id
      cinstance.application_id
    end

    def service_id
      cinstance.service.backend_id
    end

  end
end
