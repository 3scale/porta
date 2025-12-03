# frozen_string_literal: true

module ThreeScale
  module ContentSecurityPolicy
    class Base
      class << self
        def config
          @config ||= Rails.configuration.three_scale.content_security_policy
        end

        def enabled?
          config&.enabled == true
        end

        def policy_config
          raise NoMethodError, "#{__method__} not implemented in #{self.class}"
        end

        def report_only?
          config&.report_only == true
        end

        # Builds an ActionDispatch::ContentSecurityPolicy object from a policy configuration hash
        def build_policy(policy_config)
          ActionDispatch::ContentSecurityPolicy.new do |policy|
            add_policy_config(policy, policy_config)
          end
        end

        # Applies a policy configuration hash to an existing policy object
        def add_policy_config(policy, policy_config)
          policy_config.each do |directive, values|
            method_name = directive.to_s
            next unless policy.respond_to?(method_name)

            # Handle directives with sources (arrays) vs boolean directives
            if values.is_a?(Array)
              policy.public_send(method_name, *values)
            else
              policy.public_send(method_name, values)
            end
          end
        end
      end
    end

    class AdminPortal < Base
      class << self
        def policy_config
          config&.admin_portal_policy&.to_h || {}
        end
      end
    end

    class DeveloperPortal < Base
      class << self
        def policy_config
          config&.developer_portal_policy&.to_h || {}
        end
      end
    end
  end
end
