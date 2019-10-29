# frozen_string_literal: true

module BackendApiLogic
  module RoutingPolicy
    def policy_chain
      chain = super
      return chain unless with_subpaths?
      Builder.new(service).to_a.concat(chain)
    end

    def with_subpaths?
      backend_api_configs.with_subpath.any?
    end

    class Builder
      delegate :proxy, :backend_api_configs, to: :@service
      delegate :policies_config, to: :proxy

      def initialize(service)
        @service = service
      end

      def to_a
        rules = backend_api_configs.sorted_for_proxy_config.each_with_object([]) do |config, collection|
          rule = Rule.new(config).as_json
          collection << rule if rule
        end
        return [] if rules.empty?
        [{
          name: "routing",
          version: "builtin",
          enabled: true,
          configuration: {
            rules: rules
          }
        }].as_json
      end

      class Rule
        delegate :private_endpoint, :path, :backend_api_id, to: :@config

        def initialize(config)
          @config = config
        end

        def config_path
          @config_path ||= ConfigPath.new(path)
        end

        def as_json
          return if private_endpoint.blank?
          {
            url: private_endpoint,
            owner_id: backend_api_id,
            owner_type: BackendApi.name,
            condition: {
              operations: [
                match: :path,
                op: :matches,
                value: config_path.to_regex
              ]
            }
          }.merge(replace_path)
        end

        def replace_path
          return {} if config_path.blank?

          { replace_path: "{{original_request.path | remove_first: '#{config_path.path}'}}" }
        end
      end
      private_constant :Rule
    end
    private_constant :Builder

  end
end
