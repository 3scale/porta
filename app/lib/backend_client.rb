# frozen_string_literal: true

module BackendClient
  class BackendError < RuntimeError; end
  class TooManyItems < BackendError; end
  class InvalidItem  < BackendError; end

  class << self
    def threescale_client_config
      config.merge(
        port: uri.port,
        host: uri.host
      )
    end

    def config
      System::Application.config.backend_client
    end

    protected

    def uri
      URI(config[:url].presence || "#{scheme}://#{config[:host]}")
    end

    def scheme
      config[:secure] ? 'https' : 'http'
    end
  end
end
