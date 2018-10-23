# frozen_string_literal: true

# This class is a Singleton
# It retrieves OpenShift OAuth configuration
# It uses the default as described https://docs.openshift.com/container-platform/3.10/architecture/additional_concepts/authentication.html#oauth-server-metadata
module ServiceDiscovery
  # Probably could be a Singleton
  class OAuthConfiguration
    include Singleton

    attr_reader :config_fetch_retries
    delegate :authorize_endpoint, :token_endpoint, to: :oauth_configuration

    def initialize
      super
      @mutex  = Mutex.new
      @config_fetch_retries = 0
    end

    def config
      ThreeScale.config.service_discovery
    end

    def available?
      server_error? || (config.enabled && oauth_configuration.present?)
    end

    def server_error?
      @config_fetch_retries > max_retries
    end

    def max_retries
      config.max_retries || 5
    end

    # TODO: Retry strategy
    #   That can be complicated as it will be per unicorn worker
    #   and we do not want to block the server
    #   Probably this could be required at boot time
    #   then if cluster is is not available after X retries,
    #   disable the service discovery.
    def oauth_configuration
      return @oauth_configuration if @oauth_configuration

      @oauth_configuration = increment_retries_on_failure do
        request = RestClient::Request.new(
          method: :get,
          url: well_known_url,
          verify_ssl: verify_ssl,
          timeout: timeout,
          open_timeout: open_timeout
        )
        request.execute do |response|
          # TODO: rescue errors
          #   * rescue any non 200 status
          #   * rescue JSON parse error
          if response.code == 200
            json = JSON.parse(response.body)
            @oauth_configuration = ActiveSupport::OrderedOptions.new.merge(json).freeze
          else
            increment_failures
            nil
          end
        end
      end
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
      verify_ssl == OpenSSL::SSL::VERIFY_NONE
    end

    # TODO: This is not discoverable from Openshift .well-known
    # We must use `/apis/user.openshift.io/v1/users/~` See https://github.com/openshift/origin/issues/18013
    def userinfo_endpoint
      URI.join(server_url, '/apis/user.openshift.io/v1/users/~').to_s
    end

    private

    def increment_retries_on_failure
      @mutex.synchronize do
        begin
          yield
        rescue => e
          # TODO: log error
          increment_failures
          # TODO: log error
          nil
        end
      end
    end

    def increment_failures
      @config_fetch_retries += 1
    end
  end
end