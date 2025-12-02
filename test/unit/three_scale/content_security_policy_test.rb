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

    # Verify it contains expected directives
    assert policy_hash.key?(:default_src)
    assert policy_hash.key?(:script_src)
    assert policy_hash.key?(:frame_ancestors)
  end

  test 'report_only? returns false from YAML config' do
    assert_equal false, ThreeScale::ContentSecurityPolicy.report_only?
  end

  test 'report_uri returns nil from YAML config' do
    assert_nil ThreeScale::ContentSecurityPolicy.report_uri
  end

  test 'nonce_enabled? returns true from YAML config' do
    assert_equal true, ThreeScale::ContentSecurityPolicy.nonce_enabled?
  end

  test 'nonce_directives returns array from YAML config' do
    directives = ThreeScale::ContentSecurityPolicy.nonce_directives

    assert_kind_of Array, directives
    assert_includes directives, 'script-src'
    assert_includes directives, 'style-src'
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

  test 'report_uri returns nil when config is missing' do
    empty_config = ActiveSupport::OrderedOptions.new

    ThreeScale::ContentSecurityPolicy.stub :config, empty_config do
      assert_nil ThreeScale::ContentSecurityPolicy.report_uri
    end
  end

  test 'nonce_enabled? returns false when config is missing' do
    empty_config = ActiveSupport::OrderedOptions.new

    ThreeScale::ContentSecurityPolicy.stub :config, empty_config do
      assert_equal false, ThreeScale::ContentSecurityPolicy.nonce_enabled?
    end
  end

  test 'nonce_directives returns empty array when config is missing' do
    empty_config = ActiveSupport::OrderedOptions.new

    ThreeScale::ContentSecurityPolicy.stub :config, empty_config do
      directives = ThreeScale::ContentSecurityPolicy.nonce_directives

      assert_equal [], directives
    end
  end

  test 'enabled? handles nil config values gracefully' do
    config = ActiveSupport::OrderedOptions.new
    config.enabled = nil

    ThreeScale::ContentSecurityPolicy.stub :config, config do
      assert_equal false, ThreeScale::ContentSecurityPolicy.enabled?
    end
  end

  test 'nonce_enabled? handles nil config values gracefully' do
    config = ActiveSupport::OrderedOptions.new
    config.nonce_generator = nil

    ThreeScale::ContentSecurityPolicy.stub :config, config do
      assert_equal false, ThreeScale::ContentSecurityPolicy.nonce_enabled?
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
