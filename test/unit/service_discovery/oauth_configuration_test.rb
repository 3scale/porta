# frozen_string_literal: true

require 'test_helper'

class ServiceDiscovery::OAuthConfigurationTest < ActiveSupport::TestCase
  def setup

    ThreeScale.config.stubs(service_discovery: config)

    # Well I am testing ruby Singleton internal implementaton here.
    # This is really bad, but I do not find any other way to have it tested
    # WARNING: this is dangerous/leads to random failures if tests are run in threads (rails 6 feature)
    # https://github.com/rails/rails/pull/31900/files#diff-cbef10f252bdfb6975e32c5b9c32a84bR62
    ServiceDiscovery::OAuthConfiguration.instance_eval { @singleton__instance__ = nil}

    @fetcher = mock
    ServiceDiscovery::WellKnownFetcher.expects(:new).returns(@fetcher).once
  end

  def subject
    ServiceDiscovery::OAuthConfiguration.instance
  end

  test '#oauth_configuration' do
    expect_success(1)
    assert_equal well_known_response.object_id, subject.oauth_configuration.object_id
  end

  test '#oauth_configuration is nil if not enabled' do
    config.stubs(enabled: false)
    assert_nil subject.oauth_configuration
  end

  test '#oauth_configuration can be fetched' do
    expect_failure(3)

    # trying 2 times to fetch the config
    3.times do
      assert_nil subject.oauth_configuration # again
    end
    assert_equal 3, subject.retries

    # trying a 4th time does not do anything as we reached the limit
    assert_nil subject.oauth_configuration
    assert_equal 3, subject.retries
  end

  test '#oauth_configuration can be fetched after failures' do
    expect_failure(2)
    2.times do
      assert_nil subject.oauth_configuration # again
    end
    assert_equal 2, subject.retries

    expect_success(1)
    assert_equal well_known_response.object_id, subject.oauth_configuration.object_id
    assert_equal 2, subject.retries
  end

  test 'service_accessible? when not enabled' do
    config.stubs(enabled: false)
    subject.stubs(oauth_configuration: nil)
    refute subject.service_accessible?

    subject.stubs(oauth_configuration: well_known_response)
    refute subject.service_accessible?

    subject.stubs(authentication_method: ActiveSupport::StringInquirer.new('service_account'))
    refute subject.service_accessible?

    subject.stubs(oauth_configuration: nil)
    refute subject.service_accessible?

  end

  test 'service_accessible? when enabled' do
    config.stubs(enabled: true)
    subject.stubs(oauth_configuration: nil)
    refute subject.service_accessible?

    subject.stubs(oauth_configuration: well_known_response)
    assert subject.service_accessible?

    subject.stubs(authentication_method: ActiveSupport::StringInquirer.new('service_account'))
    assert subject.service_accessible?

    subject.stubs(oauth_configuration: nil)
    assert subject.service_accessible?
  end

  private

  def  config
    @config ||= ActiveSupport::OrderedOptions.new.merge(
      enabled: true,
      server_scheme: 'https',
      server_port: 8443,
      server_host: 'localhost',
      authentication_method: 'oauth',
      verify_ssl: OpenSSL::SSL::VERIFY_NONE,
      max_retry: 3
    )
  end

  def well_known_response
    @well_known_response ||= ActiveSupport::OrderedOptions.new.merge(
      issuer: 'https://127.0.0.1.nip.io:8443',
      authorization_endpoint: 'https://127.0.0.1.nip.io:8443/oauth/authorize',
      token_endpoint: 'https://127.0.0.1.nip.io:8443/oauth/token',
      scopes_supported: %w[user:check-access user:full user:info user:list-projects user:list-scoped-projects],
      response_types_supported: %w[code token],
      grant_types_supported: %w[authorization_code implicit],
      code_challenge_methods_supported: %w[plain S256],
      userinfo_endpoint: 'https://localhost:8443/apis/user.openshift.io/v1/users/~'
    )
  end

  def expect_success(times)
    @fetcher.expects(:call).times(times).returns(well_known_response)
  end

  def expect_failure(times)
    @fetcher.expects(:call).times(times)
  end
end
