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
        rules = backend_api_configs.reordering { sift(:desc, :path) }.each_with_object([]) do |config, collection|
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
        delegate :private_endpoint, :path, to: :@config

        def initialize(config)
          @config = config
        end

        def as_json
          return if private_endpoint.blank?
          {
            url: private_endpoint,
            condition: {
              operations: [
                match: :path,
                op: :matches,
                value: path_to_regex
              ]
            }
          }.merge(replace_path)
        end

        def path_to_regex
          if path.to_s.empty?
            "/.*"
          else
            "/#{path}/.*|/#{path}/?"
          end
        end

        def replace_path
          return {} if path.blank?

          private_base_path = StringUtils::StripSlash.strip_slash(URI.parse(private_endpoint).path)
          { replace_path: "{{original_request.path | replace: '/#{path}', '/#{private_base_path}'}}" }
        end
      end
      private_constant :Rule
    end
    private_constant :Builder

  end
end
