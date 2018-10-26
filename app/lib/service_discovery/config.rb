# frozen_string_literal: true
module ServiceDiscovery
  module Config
    extend ActiveSupport::Concern

    DEFAULTS = ActiveSupport::OrderedOptions.new.merge({
      enabled: false,
      server_scheme: 'https',
      server_host: 'openshift.default.svc.cluster.local',
      server_port: 443,
      authentication_method: 'service_account',
      oauth_server_type: 'builtin',
      verify_ssl: OpenSSL::SSL::VERIFY_NONE,
      max_retry: 5,
      timeout: 1,
      open_timeout: 1
    }).freeze


    # All those methods are now private in the receiver, due to the use of module_function
    # To query any of the methods outside of any receiver, just use _ServiceDiscovery::Config._method_
    delegate :enabled, :bearer_token, :client_id, :client_secret, to: :config
    delegate :oauth?, :service_account?, to: :authentication_method
    delegate :rh_sso?, :builtin?, to: :oauth_server_type

    module_function :enabled, :bearer_token, :client_id, :client_secret, :oauth?, :service_account?, :rh_sso?, :builtin?

    module_function

    def config
      ThreeScale.config.service_discovery
    end

    def server_scheme
      config.server_scheme.presence || DEFAULTS.server_scheme
    end

    def server_host
      config.server_host.presence ||  DEFAULTS.server_host
    end

    def server_port
      config.server_port.presence || DEFAULTS.server_port
    end

    def verify_ssl
      config.verify_ssl.presence || DEFAULTS.verify_ssl
    end

    def timeout
      config.timeout.presence || DEFAULTS.timeout
    end

    def open_timeout
      config.open_timeout.presence || DEFAULTS.open_timeout
    end

    def max_retry
      config.max_retry.presence || DEFAULTS.max_retry
    end

    def authentication_method
      ActiveSupport::StringInquirer.new(config.authentication_method.presence || DEFAULTS.authentication_method)
    end

    def oauth_server_type
      ActiveSupport::StringInquirer.new(ThreeScale.config.service_discovery.oauth_server_type.presence || DEFAULTS.oauth_server_type)
    end

    def server_url
      "#{server_scheme}://#{server_host}:#{server_port}"
    end

    def well_known_url
      "#{server_url}/.well-known/oauth-authorization-server"
    end

    def verify_ssl?
      verify_ssl != OpenSSL::SSL::VERIFY_NONE
    end
  end
end
