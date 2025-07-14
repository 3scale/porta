require 'hashie/mash'

module Apicast
  class ProviderSource
    attr_reader :provider

    def initialize(provider)
      @provider = provider
    end

    def reload
      @provider.reload
      self
    end

    delegate :services, :provider_key, :id, to: :mash

    SERVICE_SERIALIZE_OPTIONS = {
      except: Service.ignored_columns,
      methods: [:proxiable?, :backend_authentication_type, :backend_authentication_value, :updated_at],
      include: [
        proxy: {
          except: [:policies_config],
          methods: [
            :oauth_login_url, :hostname_rewrite_for_sandbox, :endpoint_port, :api_backend, :valid?, :service_backend_version,
            :hosts, :backend, :policy_chain, *GatewayConfiguration::ATTRIBUTES
          ],
          include: [
            proxy_rules: {
              methods: [
                :parameters, :querystring_parameters
              ]
            }
          ]
        }
      ]
    }.freeze

    def attributes_for_proxy
      hash = {
        root: false,
        only: [:id],
        methods: [:provider_key],
        include: [
          services: SERVICE_SERIALIZE_OPTIONS.dup
        ]
      }

      ActiveRecord::Associations::Preloader.new(records: Array(provider), associations: {services: [:service_tokens, {backend_api_configs: :backend_api, proxy: [:gateway_configuration, {proxy_rules: :metric}]}]}).call
      provider.as_json(hash).merge(timestamp: Time.now.utc.iso8601)
    end

    protected

    # this is probably not valid
    def provider_methods
      provider.provider_can_use?(:apicast_v2) ? [] : [:provider_key]
    end

    def mash
      Hashie::Mash.new(attributes_for_proxy)
    end
  end
end
