# frozen_string_literal: true

# Configure Content Security Policy headers
# See: https://guides.rubyonrails.org/security.html#content-security-policy-header

require_dependency 'three_scale/content_security_policy'

if ThreeScale::ContentSecurityPolicy::AdminPortal.enabled?
  # Apply configurable CSP from YAML
  Rails.application.configure do
    # Set report-only mode if configured
    config.content_security_policy_report_only = true if ThreeScale::ContentSecurityPolicy::AdminPortal.report_only?
  end

  # Apply global CSP policy from configuration
  Rails.application.config.to_prepare do
    policy_config = ThreeScale::ContentSecurityPolicy::AdminPortal.policy_config

    if policy_config.present?
      Rails.application.config.content_security_policy do |policy|
        ThreeScale::ContentSecurityPolicy::AdminPortal.add_policy_config(policy, policy_config)
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
