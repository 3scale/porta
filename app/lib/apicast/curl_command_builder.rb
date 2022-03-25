# frozen_string_literal: true

module Apicast
  class CurlCommandBuilder
    class Builder
      def initialize(proxy, test_path: nil)
        @proxy = proxy
        @test_path = test_path
      end

      attr_reader :proxy, :test_path

      def command
        return unless proxy
        return if base_endpoint.blank?

        credentials = proxy.authentication_params_for_proxy
        extheaders = ''

        uri = uri_base_endpoint
        return unless uri

        uri.path, uri.query = path_and_query

        case proxy.credentials_location
        when 'headers'
          credentials.each { |k, v| extheaders += " -H'#{k}: #{v}'" }
        when 'query'
          uri.query_values = (uri.query_values || {}).merge(credentials)
        when 'authorization'
          uri.user, uri.password = proxy.authorization_credentials
        end

        "curl \"#{uri}\" #{extheaders}"
      end

      protected

      def uri_base_endpoint
        Addressable::URI.parse(base_endpoint)
      rescue Addressable::URI::InvalidURIError
        nil
      end

      def base_endpoint
        raise NoMethodError, __method__
      end

      def path_and_query
        path = test_path || first_proxy_rule_pattern
        uri = Addressable::URI.parse(path)
        [uri.path, uri.query]
      end

      def first_proxy_rule_pattern
        proxy_rules = proxy.proxy_rules
        proxy_rules.any? ? proxy_rules.first[:pattern] : '/'
      end
    end

    class StagingBuilder < Builder
      def base_endpoint
        proxy.sandbox_endpoint
      end
    end

    class ProductionBuilder < Builder
      def base_endpoint
        proxy.default_production_endpoint
      end
    end

    # It quacks like a Proxy but it's actually a json proxy config
    class ProxyFromConfig
      def initialize(config)
        @config = config
      end

      attr_reader :config

      delegate :sandbox_endpoint, :credentials_location, :api_test_path, :proxy_rules, to: :proxy

      def default_production_endpoint
        proxy.endpoint
      end

      def authentication_params_for_proxy(opts = {})
        params = service.plugin_authentication_params
        keys_to_proxy_args = { app_key: :auth_app_key, app_id: :auth_app_id, user_key: :auth_user_key }
        params.keys.map do |key|
          param_name = opts[:original_names] ? key.to_s : proxy.send(keys_to_proxy_args[key])
          [param_name, params[key]]
        end.to_h
      end

      def authorization_credentials
        params = authentication_params_for_proxy.symbolize_keys
        params.values_at(:user_key).compact.presence || params.values_at(:app_id, :app_key)
      end

      protected

      def proxy
        @proxy ||= ActiveSupport::OrderedOptions.new.merge(config[:proxy])
      end

      def service
        @service ||= Service.find(proxy.service_id)
      end
    end

    def initialize(proxy, environment: :staging)
      @proxy = proxy
      @environment = environment
      @builder = builder_class.new(proxy_from_config)
    end

    attr_reader :proxy, :environment, :builder

    delegate :command, to: :builder
    delegate :to_s, to: :command

    protected

    def builder_class
      case environment.to_sym
      when :staging, :sandbox
        StagingBuilder
      when :production
        ProductionBuilder
      else
        raise
      end
    end

    def proxy_from_config
      proxy_config = proxy.proxy_configs.by_environment(environment.to_s).newest_first.first
      ProxyFromConfig.new(proxy_config.parsed_content) if proxy_config
    end
  end
end
