require 'test_helper'

class ThreeScale::ContentSecurityPolicyTest < ActiveSupport::TestCase
  test 'config returns Rails configuration for CSP' do
    config = ThreeScale::ContentSecurityPolicy.config

    assert_not_nil config
    assert_kind_of ActiveSupport::OrderedOptions, config
  end

  test 'enabled? returns false in test environment' do
    assert_equal false, ThreeScale::ContentSecurityPolicy.enabled?
  end

  test 'policy_config returns hash of CSP directives from YAML' do
    policy_hash = ThreeScale::ContentSecurityPolicy.policy_config

    assert_kind_of Hash, policy_hash
    assert policy_hash.present?

    # Verify it contains the permissive default_src directive
    assert policy_hash.key?(:default_src)
    assert_includes policy_hash[:default_src], '*'
    assert_includes policy_hash[:default_src], "'unsafe-inline'"
    assert_includes policy_hash[:default_src], "'unsafe-eval'"
  end

  test 'report_only? returns false from YAML config' do
    assert_equal false, ThreeScale::ContentSecurityPolicy.report_only?
  end

  test 'policy_config returns empty hash when config.policy is nil' do
    ThreeScale::ContentSecurityPolicy.config.stub :policy, nil do
      policy_hash = ThreeScale::ContentSecurityPolicy.policy_config

      assert_equal({}, policy_hash)
    end
  end
end

class ThreeScale::ContentSecurityPolicyWithoutYAMLTest < ActiveSupport::TestCase
  test 'enabled? returns false when config is missing' do
    empty_config = ActiveSupport::OrderedOptions.new

    ThreeScale::ContentSecurityPolicy.stub :config, empty_config do
      assert_equal false, ThreeScale::ContentSecurityPolicy.enabled?
    end
  end

  test 'policy_config returns empty hash when config is missing' do
    empty_config = ActiveSupport::OrderedOptions.new

    ThreeScale::ContentSecurityPolicy.stub :config, empty_config do
      policy_hash = ThreeScale::ContentSecurityPolicy.policy_config

      assert_equal({}, policy_hash)
    end
  end

  test 'report_only? returns false when config is missing' do
    empty_config = ActiveSupport::OrderedOptions.new

    ThreeScale::ContentSecurityPolicy.stub :config, empty_config do
      assert_equal false, ThreeScale::ContentSecurityPolicy.report_only?
    end
  end

  test 'enabled? handles nil config values gracefully' do
    config = ActiveSupport::OrderedOptions.new
    config.enabled = nil

    ThreeScale::ContentSecurityPolicy.stub :config, config do
      assert_equal false, ThreeScale::ContentSecurityPolicy.enabled?
    end
  end

  test 'report_only? handles nil config values gracefully' do
    config = ActiveSupport::OrderedOptions.new
    config.report_only = nil

    ThreeScale::ContentSecurityPolicy.stub :config, config do
      assert_equal false, ThreeScale::ContentSecurityPolicy.report_only?
    end
  end
end
