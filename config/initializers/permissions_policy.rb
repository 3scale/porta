# frozen_string_literal: true

# Configure Permissions-Policy headers (formerly Feature-Policy)
# See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Permissions-Policy

require 'three_scale/permissions_policy'

Rails.application.configure do
  if ThreeScale::PermissionsPolicy::AdminPortal.enabled?
    policy_config = ThreeScale::PermissionsPolicy::AdminPortal.policy_config

    if policy_config.present?
      config.permissions_policy do |policy|
        ThreeScale::PermissionsPolicy::AdminPortal.add_policy_config(policy, policy_config)
      end
    end
  end
  # When disabled, no Permissions-Policy header is set (permissive by default)
end
