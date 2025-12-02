# frozen_string_literal: true

module ThreeScale
  module ContentSecurityPolicy
    class << self
      def config
        @config ||= Rails.configuration.three_scale.content_security_policy
      end

      def enabled?
        config&.enabled == true
      end

      def policy_config
        config&.policy&.to_h || {}
      end

      def report_only?
        config&.report_only == true
      end

      def report_uri
        config&.report_uri.presence
      end

      def nonce_enabled?
        config&.nonce_generator == true
      end

      def nonce_directives
        config&.nonce_directives&.map(&:to_s) || []
      end
    end
  end
end
