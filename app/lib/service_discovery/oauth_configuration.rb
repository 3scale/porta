# frozen_string_literal: true

# This class is a Singleton
# It retrieves OpenShift OAuth configuration
# It uses the default as described https://docs.openshift.com/container-platform/3.10/architecture/additional_concepts/authentication.html#oauth-server-metadata
module ServiceDiscovery
  # Probably could be a Singleton
  class OAuthConfiguration
    include Singleton

    attr_reader :config_fetch_retries
    delegate :authorization_endpoint, :userinfo_endpoint, :token_endpoint, to: :oauth_configuration, allow_nil: true
    delegate :verify_ssl?, to: :@well_known

    def initialize
      super
      @mutex  = Mutex.new
      @config_fetch_retries = 0
      @well_known = WellKnownFetcher.new
    end

    def config
      ThreeScale.config.service_discovery
    end

    def available?
      oauth_configuration.present?
    end

    def max_retries
      config.max_retries || 5
    end

    def oauth_configuration
      return unless config.enabled && server_ok?
      return @oauth_configuration if @oauth_configuration
      increment_retries_on_failure do
        @oauth_configuration = @well_known.call
      end
    end

    def server_ok?
      @config_fetch_retries < max_retries
    end

    def client_secret
      config.client_secret
    end

    def client_id
      config.client_id
    end

    private

    def increment_retries_on_failure
      @mutex.synchronize do
        yield.tap { |result| increment_failures unless result }
      end
    end

    def increment_failures
      @config_fetch_retries += 1
    end

    class WellKnownFetcher
      delegate :well_known_url, :verify_ssl, :timeout, :open_timeout, to: :config

      def config
        ThreeScale.config.service_discovery
      end

      def timeout
        config.timeout || 1
      end

      def open_timeout
        config.open_timeout || 1
      end

      def well_known_url
        URI.join(server_url, '.well-known/oauth-authorization-server').to_s
      end

      def server_url
        URI::Generic.build(scheme: server_scheme, host: server_host, port: server_port).to_s
      end

      def server_host
        config.server_host || 'openshift.default.svc'
      end

      def server_port
        config.server_port || 8443
      end

      def server_scheme
        config.server_scheme || 'https'
      end

      def verify_ssl
        config.verify_ssl || OpenSSL::SSL::VERIFY_NONE
      end

      def verify_ssl?
        verify_ssl != OpenSSL::SSL::VERIFY_NONE
      end

      # TODO: Retry strategy
      #   That can be complicated as it will be per unicorn worker
      #   and we do not want to block the server
      #   Probably this could be required at boot time
      #   then if cluster is is not available after X retries,
      #   disable the service discovery.
      def call
        request = RestClient::Request.new(
          method: :get,
          url: well_known_url,
          verify_ssl: verify_ssl,
          timeout: timeout,
          open_timeout: open_timeout
        )
        request.execute do |response|
          if response.code == 200
            json = JSON.parse(response.body)
            # The endpoint could be better in case of Keycloak
            json.merge!(userinfo_endpoint: URI.join(server_url, '/apis/user.openshift.io/v1/users/~').to_s)
            ActiveSupport::OrderedOptions.new.merge!(json.symbolize_keys).freeze
          else
            nil
          end
        end
      rescue => e
        # TODO: Improve error logging
        Rails.logger.debug("[Service Discovery] Cannot fetch the #{well_known_url} configuration. Exception: #{e.message}")
        nil
      end
    end

  end
end
