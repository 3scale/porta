# frozen_string_literal: true

module ThreeScale
  module Middleware
    class DeveloperPortalPermissionsPolicy

      attr_reader :permissions_policy_header_value

      def initialize(app)
        @app = app

        # Pre-compute the Permissions-Policy header once at startup
        @permissions_policy_header_value = compute_permissions_policy_header
      end

      def call(env)
        if permissions_policy_header_value.blank?
          request = ActionDispatch::Request.new(env)
          request.permissions_policy = nil
          return @app.call(env)
        end

        _status, headers, _body = response = @app.call(env)

        # Only apply if we have a pre-computed header
        headers[ActionDispatch::Constants::FEATURE_POLICY] = permissions_policy_header_value

        response
      end

      private

      def compute_permissions_policy_header
        policy_config = ThreeScale::PermissionsPolicy::DeveloperPortal.policy_config

        # When disabled or no policy configured, don't set any header (permissive by default)
        return nil unless ThreeScale::PermissionsPolicy::DeveloperPortal.enabled? && policy_config.present?

        # Build the policy once at initialization
        policy = ThreeScale::PermissionsPolicy::DeveloperPortal.build_policy(policy_config)
        header_value = policy.build

        # Don't set an empty header
        return nil if header_value.blank?

        header_value
      end
    end
  end
end
