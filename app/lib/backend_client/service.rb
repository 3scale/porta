module BackendClient
  class Service < Base
    attr_reader :connection
    attr_reader :service

    delegate :account, :to => :service

    http_methods :get, :post, :delete do |method, path, params|
      connection.send(method, path, params.merge(:provider_key => provider_key))
    end

    def initialize(connection, service)
      @connection = connection
      @service    = service
    end

    def provider_key
      @provider_key ||= service.account.api_key
    end

    def service_id
      service.backend_id
    end
  end
end
