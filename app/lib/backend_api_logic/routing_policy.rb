# frozen_string_literal: true

module BackendApiLogic
  module RoutingPolicy
    def policy_chain
      chain = super
      return chain unless with_subpaths?

      other_routing_policies, other_policies = chain.partition { |policy| policy['name'] == 'routing' }
      other_routing_rules = other_routing_policies.flat_map { |policy| policy['configuration']['rules'] }

      routing_policy = Builder.new(service).to_h

      return other_policies if routing_policy['configuration']['rules'].concat(other_routing_rules).empty?

      apicast_policy_index = other_policies.index { |policy| policy['name'] == 'apicast'}
      other_policies.insert(apicast_policy_index, routing_policy).compact
    end

    def with_subpaths?
      backend_api_configs.any?(&:with_subpath?)
    end

    class Builder
      delegate :proxy, :backend_api_configs, to: :@service
      delegate :policies_config, to: :proxy

      def initialize(service)
        @service = service
      end

      def to_h
        rules = backend_api_configs.sorted_for_proxy_config.each_with_object([]) do |config, collection|
          rule = Rule.new(config).as_json
          collection << rule if rule
        end
        {
          name: "routing",
          version: "builtin",
          enabled: true,
          configuration: {
            rules: rules
          }
        }.as_json
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

          { replace_path: "{{uri | remove_first: '#{config_path.path}'}}" }
        end
      end
      private_constant :Rule
    end
    private_constant :Builder

  end
end
