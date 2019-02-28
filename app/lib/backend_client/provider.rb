module BackendClient
  class Provider < Base

    attr_reader :connection
    attr_reader :account

    http_methods :get, :post, :delete do |method, path, params|
      connection.send(method, path, params.merge(:provider_key => provider_key))
    end

    def initialize(connection, account)
      @connection = connection
      @account    = account
    end

    def provider_key
      @provider_key ||= account.api_key
    end

    def application(cinstance)
      BackendClient::Application.new(self, cinstance)
    end

  end
end
