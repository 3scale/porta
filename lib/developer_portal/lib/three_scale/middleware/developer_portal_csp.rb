# frozen_string_literal: true

module ThreeScale
  module Middleware
    class DeveloperPortalCSP
      def initialize(app)
        @app = app

        # Pre-compute the CSP header once at startup since we don't use nonces or dynamic sources
        @csp_header_name, @csp_header_value = compute_csp_header
      end

      def call(env)
        request = ActionDispatch::Request.new(env)

        # We want to apply CSP only for HTML requests. However, we can't just return
        # because Rails will add global CSP policy (admin portal policy) to the response
        # if we don't do anything. We disable CSP for this request to prevent Rails middleware
        # to interfere.
        unless request.format.html?
          request.content_security_policy = false
          return @app.call(env)
        end

        status, headers, _body = response = @app.call(env)

        # Don't apply CSP to 304 responses to avoid cache issues
        return response if status == 304

        # Only apply if we have a pre-computed CSP header
        headers[@csp_header_name] = @csp_header_value if @csp_header_value

        response
      end

      private

      def compute_csp_header
        # Only compute if enabled and there's a policy configured
        policy_config = ThreeScale::ContentSecurityPolicy::DeveloperPortal.policy_config

        unless ThreeScale::ContentSecurityPolicy::DeveloperPortal.enabled? && policy_config.present?
          policy = ThreeScale::ContentSecurityPolicy::DeveloperPortal.build_policy(
            ThreeScale::ContentSecurityPolicy::DeveloperPortal::DEFAULT_POLICY
          )

          return [
            ActionDispatch::Constants::CONTENT_SECURITY_POLICY,
            policy.build
          ]
        end

        # Build the policy once at initialization
        policy = ThreeScale::ContentSecurityPolicy::DeveloperPortal.build_policy(policy_config)
        header_name = if ThreeScale::ContentSecurityPolicy::DeveloperPortal.report_only?
                        ActionDispatch::Constants::CONTENT_SECURITY_POLICY_REPORT_ONLY
                      else
                        ActionDispatch::Constants::CONTENT_SECURITY_POLICY
                      end
        header_value = policy.build

        [header_name, header_value]
      end
    end
  end
end
