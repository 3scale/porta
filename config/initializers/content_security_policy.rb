# frozen_string_literal: true

# Configure Content Security Policy headers
# See: https://guides.rubyonrails.org/security.html#content-security-policy-header

require_dependency 'three_scale/content_security_policy'

if ThreeScale::ContentSecurityPolicy.enabled?
  # Apply configurable CSP from YAML
  Rails.application.configure do
    # Set report-only mode if configured
    config.content_security_policy_report_only = true if ThreeScale::ContentSecurityPolicy.report_only?
  end

  # Apply global CSP policy from configuration
  Rails.application.config.to_prepare do
    policy_config = ThreeScale::ContentSecurityPolicy.policy_config

    if policy_config.present?
      Rails.application.config.content_security_policy do |policy|
        # Apply each directive from YAML config
        policy_config.each do |directive, value|
          method_name = directive.to_s
          next unless policy.respond_to?(method_name)

          # Handle directives with sources (arrays) vs boolean directives
          if value.is_a?(Array)
            policy.public_send(method_name, *value)
          else
            policy.public_send(method_name, value)
          end
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
