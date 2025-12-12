require 'test_helper'

class ThreeScale::ContentSecurityPolicy::AdminPortalTest < ActiveSupport::TestCase
  test 'config returns Rails configuration for CSP' do
    config = ThreeScale::ContentSecurityPolicy::AdminPortal.config

    assert_not_nil config
    assert_kind_of ActiveSupport::OrderedOptions, config
  end

  test 'enabled? returns true in test environment' do
    assert_equal true, ThreeScale::ContentSecurityPolicy::AdminPortal.enabled?
  end

  test 'policy_config returns hash of CSP directives from YAML' do
    policy_hash = ThreeScale::ContentSecurityPolicy::AdminPortal.policy_config

    assert_kind_of Hash, policy_hash
    assert policy_hash.present?

    # Verify it contains restrictive directives
    assert policy_hash.key?(:default_src)
    assert_includes policy_hash[:default_src], "'self'"
    assert policy_hash.key?(:script_src)
    assert_includes policy_hash[:script_src], "'self'"
  end

  test 'report_only? returns false from YAML config' do
    assert_equal false, ThreeScale::ContentSecurityPolicy::AdminPortal.report_only?
  end

  test 'policy_config returns empty hash when config.admin_portal_policy is nil' do
    ThreeScale::ContentSecurityPolicy::AdminPortal.config.stubs(:admin_portal_policy).returns(nil)
    policy_hash = ThreeScale::ContentSecurityPolicy::AdminPortal.policy_config

    assert_equal({}, policy_hash)
  end
end

class ThreeScale::ContentSecurityPolicy::DeveloperPortalTest < ActiveSupport::TestCase
  test 'config returns Rails configuration for CSP' do
    config = ThreeScale::ContentSecurityPolicy::DeveloperPortal.config

    assert_not_nil config
    assert_kind_of ActiveSupport::OrderedOptions, config
  end

  test 'enabled? returns true in test environment' do
    assert_equal true, ThreeScale::ContentSecurityPolicy::DeveloperPortal.enabled?
  end

  test 'policy_config returns hash of CSP directives from YAML' do
    policy_hash = ThreeScale::ContentSecurityPolicy::DeveloperPortal.policy_config

    assert_kind_of Hash, policy_hash
    assert policy_hash.present?

    # Verify it contains the permissive default_src directive
    assert policy_hash.key?(:default_src)
    assert_includes policy_hash[:default_src], "*"
    assert_includes policy_hash[:default_src], "'unsafe-eval'"
    assert_includes policy_hash[:default_src], "'unsafe-inline'"
  end

  test 'report_only? returns false from YAML config' do
    assert_equal false, ThreeScale::ContentSecurityPolicy::DeveloperPortal.report_only?
  end

  test 'policy_config returns empty hash when config.developer_portal_policy is nil' do
    ThreeScale::ContentSecurityPolicy::DeveloperPortal.config.stubs(:developer_portal_policy).returns(nil)
    policy_hash = ThreeScale::ContentSecurityPolicy::DeveloperPortal.policy_config

    assert_equal({}, policy_hash)
  end
end

class ThreeScale::ContentSecurityPolicyWithoutYAMLTest < ActiveSupport::TestCase
  test 'AdminPortal enabled? returns false when config is missing' do
    empty_config = ActiveSupport::OrderedOptions.new
    ThreeScale::ContentSecurityPolicy::AdminPortal.stubs(:config).returns(empty_config)

    assert_equal false, ThreeScale::ContentSecurityPolicy::AdminPortal.enabled?
  end

  test 'AdminPortal policy_config returns empty hash when config is missing' do
    empty_config = ActiveSupport::OrderedOptions.new
    ThreeScale::ContentSecurityPolicy::AdminPortal.stubs(:config).returns(empty_config)

    policy_hash = ThreeScale::ContentSecurityPolicy::AdminPortal.policy_config

    assert_equal({}, policy_hash)
  end

  test 'AdminPortal report_only? returns false when config is missing' do
    empty_config = ActiveSupport::OrderedOptions.new
    ThreeScale::ContentSecurityPolicy::AdminPortal.stubs(:config).returns(empty_config)

    assert_equal false, ThreeScale::ContentSecurityPolicy::AdminPortal.report_only?
  end

  test 'AdminPortal enabled? handles nil config values gracefully' do
    config = ActiveSupport::OrderedOptions.new
    config.enabled = nil
    ThreeScale::ContentSecurityPolicy::AdminPortal.stubs(:config).returns(config)

    assert_equal false, ThreeScale::ContentSecurityPolicy::AdminPortal.enabled?
  end

  test 'AdminPortal report_only? handles nil config values gracefully' do
    config = ActiveSupport::OrderedOptions.new
    config.admin_portal_report_only = nil
    ThreeScale::ContentSecurityPolicy::AdminPortal.stubs(:config).returns(config)

    assert_equal false, ThreeScale::ContentSecurityPolicy::AdminPortal.report_only?
  end
end
