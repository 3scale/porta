# frozen_string_literal: true

require 'test_helper'

class ThreeScale::PermissionsPolicy::BaseTest < ActiveSupport::TestCase
  test 'config returns Rails configuration for Permissions-Policy' do
    config = ThreeScale::PermissionsPolicy::AdminPortal.config

    assert_not_nil config
    assert_kind_of ActiveSupport::OrderedOptions, config
  end

  test 'build_policy creates an ActionDispatch::PermissionsPolicy object' do
    policy_config = ThreeScale::PermissionsPolicy::AdminPortal.policy_config

    policy = ThreeScale::PermissionsPolicy::AdminPortal.build_policy(policy_config)

    assert_kind_of ActionDispatch::PermissionsPolicy, policy
    header_value = policy.build
    assert_includes header_value, 'camera'
    assert_includes header_value, 'fullscreen'
  end

  test 'add_policy_config applies policy configuration to existing policy' do
    policy = ActionDispatch::PermissionsPolicy.new
    policy_config = ThreeScale::PermissionsPolicy::AdminPortal.policy_config

    ThreeScale::PermissionsPolicy::AdminPortal.add_policy_config(policy, policy_config)

    header_value = policy.build
    assert_includes header_value, 'camera'
    assert_includes header_value, 'microphone'
  end

  test 'add_policy_config skips unknown directives' do
    policy = ActionDispatch::PermissionsPolicy.new
    policy_config = { unknown_directive: ["'none'"], camera: ["'none'"] }

    # Should not raise an error
    ThreeScale::PermissionsPolicy::AdminPortal.add_policy_config(policy, policy_config)

    header_value = policy.build
    assert_includes header_value, 'camera'
    assert_not_includes header_value, 'unknown_directive'
  end

  test 'add_policy_config handles URLs as allowed origins' do
    policy = ActionDispatch::PermissionsPolicy.new
    policy_config = { payment: ["'self'", 'https://secure.example.com'] }

    ThreeScale::PermissionsPolicy::AdminPortal.add_policy_config(policy, policy_config)

    header_value = policy.build
    assert_includes header_value, 'payment'
    assert_includes header_value, 'https://secure.example.com'
  end

  test 'add_policy_config handles array values' do
    policy = ActionDispatch::PermissionsPolicy.new
    policy_config = { camera: ["'self'", 'https://example.com'] }

    ThreeScale::PermissionsPolicy::AdminPortal.add_policy_config(policy, policy_config)

    header_value = policy.build
    assert_includes header_value, "camera 'self' https://example.com"
  end

  test 'add_policy_config handles non-array values' do
    policy = ActionDispatch::PermissionsPolicy.new
    policy_config = { camera: "'none'" }

    ThreeScale::PermissionsPolicy::AdminPortal.add_policy_config(policy, policy_config)

    header_value = policy.build
    assert_includes header_value, "camera 'none'"
  end
end

class ThreeScale::PermissionsPolicy::AdminPortalTest < ActiveSupport::TestCase
  test 'enabled? returns true in test environment' do
    assert_equal true, ThreeScale::PermissionsPolicy::AdminPortal.enabled?
  end

  test 'policy_config returns hash of Permissions-Policy directives from YAML' do
    policy_hash = ThreeScale::PermissionsPolicy::AdminPortal.policy_config

    assert_kind_of Hash, policy_hash
    assert policy_hash.present?

    # Verify it contains restrictive directives from the YAML config
    assert policy_hash.key?(:camera)
    assert_includes policy_hash[:camera], "'none'"
    assert policy_hash.key?(:fullscreen)
    assert_includes policy_hash[:fullscreen], "'self'"
  end

  test 'policy_config returns empty hash when config.admin_portal.policy is nil' do
    admin_portal_config = ActiveSupport::OrderedOptions.new
    admin_portal_config.policy = nil
    ThreeScale::PermissionsPolicy::AdminPortal.config.stubs(:admin_portal).returns(admin_portal_config)
    policy_hash = ThreeScale::PermissionsPolicy::AdminPortal.policy_config

    assert_equal({}, policy_hash)
  end
end

class ThreeScale::PermissionsPolicy::DeveloperPortalTest < ActiveSupport::TestCase
  test 'enabled? returns true in test environment' do
    assert_equal true, ThreeScale::PermissionsPolicy::DeveloperPortal.enabled?
  end

  test 'policy_config returns hash of Permissions-Policy directives from YAML' do
    policy_hash = ThreeScale::PermissionsPolicy::DeveloperPortal.policy_config

    assert_kind_of Hash, policy_hash
    # Developer portal has empty policy by default (permissive)
    assert policy_hash.empty?
  end

  test 'policy_config returns empty hash when config.developer_portal.policy is nil' do
    developer_portal_config = ActiveSupport::OrderedOptions.new
    developer_portal_config.policy = nil
    ThreeScale::PermissionsPolicy::DeveloperPortal.config.stubs(:developer_portal).returns(developer_portal_config)
    policy_hash = ThreeScale::PermissionsPolicy::DeveloperPortal.policy_config

    assert_equal({}, policy_hash)
  end
end

class ThreeScale::PermissionsPolicyWithoutYAMLTest < ActiveSupport::TestCase
  test 'AdminPortal enabled? returns false when config is missing' do
    empty_config = ActiveSupport::OrderedOptions.new
    ThreeScale::PermissionsPolicy::AdminPortal.stubs(:config).returns(empty_config)

    assert_equal false, ThreeScale::PermissionsPolicy::AdminPortal.enabled?
  end

  test 'AdminPortal enabled? handles nil config values gracefully' do
    config = ActiveSupport::OrderedOptions.new
    admin_portal_config = ActiveSupport::OrderedOptions.new
    admin_portal_config.enabled = nil
    config.admin_portal = admin_portal_config
    ThreeScale::PermissionsPolicy::AdminPortal.stubs(:config).returns(config)

    assert_equal false, ThreeScale::PermissionsPolicy::AdminPortal.enabled?
  end

  test 'AdminPortal policy_config returns empty hash when config is missing' do
    empty_config = ActiveSupport::OrderedOptions.new
    ThreeScale::PermissionsPolicy::AdminPortal.stubs(:config).returns(empty_config)

    policy_hash = ThreeScale::PermissionsPolicy::AdminPortal.policy_config

    assert_equal({}, policy_hash)
  end
end
