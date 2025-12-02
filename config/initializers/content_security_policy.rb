# frozen_string_literal: true

# Configure Content Security Policy headers
# See: https://guides.rubyonrails.org/security.html#content-security-policy-header

require_dependency 'three_scale/content_security_policy'

if ThreeScale::ContentSecurityPolicy.enabled?
  # Apply configurable CSP from YAML
  Rails.application.configure do
    # Configure nonce generation if enabled
    if ThreeScale::ContentSecurityPolicy.nonce_enabled?
      config.content_security_policy_nonce_generator = ->(request) {
        SecureRandom.base64(16)
      }

      nonce_directives = ThreeScale::ContentSecurityPolicy.nonce_directives
      config.content_security_policy_nonce_directives = nonce_directives unless nonce_directives.empty?
    end

    # Set report-only mode if configured
    if ThreeScale::ContentSecurityPolicy.report_only?
      config.content_security_policy_report_only = true
    end
  end

  # Apply global CSP policy from configuration
  Rails.application.config.to_prepare do
    policy_config = ThreeScale::ContentSecurityPolicy.policy_config

    if policy_config.present?
      Rails.application.config.content_security_policy do |policy|
        # Apply each directive from YAML config
        policy_config.each do |directive, sources|
          next unless sources.is_a?(Array)

          method_name = directive.to_s
          if policy.respond_to?(method_name)
            policy.public_send(method_name, *sources)
          end
        end

        # Add report-uri if configured
        if (uri = ThreeScale::ContentSecurityPolicy.report_uri)
          policy.report_uri uri
        end
      end
    end
  end
else
  # Fallback to permissive policy when config is disabled
  Rails.application.config.to_prepare do
    Rails.application.config.content_security_policy do |policy|
      policy.default_src '*', :data, :mediastream, :blob, :filesystem, :ws, :wss, :unsafe_eval, :unsafe_inline
    end
  end
end
