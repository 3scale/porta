# frozen_string_literal: true

module ThreeScale
  module Middleware
    class DeveloperPortalCSP
      def initialize(app)
        @app = app
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

        # Returning CSP headers with a 304 Not Modified is harmful, since nonces in the new
        # CSP headers might not match nonces in the cached HTML (if we add nonce support later).
        return response if status == 304

        # Only apply if enabled and there's a policy configured
        policy_config = ThreeScale::ContentSecurityPolicy::DeveloperPortal.policy_config
        return response unless ThreeScale::ContentSecurityPolicy::DeveloperPortal.enabled? && policy_config.present?

        # Build Rails ContentSecurityPolicy object from our config and use its build method
        policy = ThreeScale::ContentSecurityPolicy::DeveloperPortal.build_policy(policy_config)
        header_name = if ThreeScale::ContentSecurityPolicy::DeveloperPortal.report_only?
                        ActionDispatch::Constants::CONTENT_SECURITY_POLICY_REPORT_ONLY
                      else
                        ActionDispatch::Constants::CONTENT_SECURITY_POLICY
                      end
        headers[header_name] = policy.build

        response
      end
    end
  end
end
