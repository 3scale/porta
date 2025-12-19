# frozen_string_literal: true

# Configure Content Security Policy headers
# See: https://guides.rubyonrails.org/security.html#content-security-policy-header

require 'three_scale/content_security_policy'

Rails.application.configure do
  if ThreeScale::ContentSecurityPolicy::AdminPortal.enabled?
    policy_config = ThreeScale::ContentSecurityPolicy::AdminPortal.policy_config

    if policy_config.present?
      config.content_security_policy do |policy|
        ThreeScale::ContentSecurityPolicy::AdminPortal.add_policy_config(policy, policy_config)
      end
    end

    # Set report-only mode if configured
    config.content_security_policy_report_only = true if ThreeScale::ContentSecurityPolicy::AdminPortal.report_only?
  else
    config.content_security_policy do |policy|
      policy.default_src '*', :data, :mediastream, :blob, :filesystem, :ws, :wss, :unsafe_eval, :unsafe_inline
    end
  end
end
