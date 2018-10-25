# frozen_string_literal: true

require 'test_helper'

class ServiceDiscovery::OAuthConfigurationTest < ActiveSupport::TestCase
  def setup
    config = ActiveSupport::OrderedOptions.new
    config.merge!(
      enabled: true,
      server_scheme: 'https',
      server_port: 8443,
      server_host: 'localhost',
      authentication_method: 'oauth',
      verify_ssl: OpenSSL::SSL::VERIFY_NONE
    )
    ThreeScale.config.stubs(service_discovery: config)

    # Well I am testing ruby Singleton internal implementaton here.
    # This is really bad, but I do not find any other way to have it tested
    ServiceDiscovery::OAuthConfiguration.instance_eval { @singleton__instance__ = nil}
  end

  def subject
    ServiceDiscovery::OAuthConfiguration.instance
  end

  test '#config' do
    assert_equal ThreeScale.config.service_discovery, subject.config
  end

  test '#available?' do

  end

  test '#oauth_configuration' do
    stub_success

    config = subject.oauth_configuration
    subject.oauth_configuration # again
    assert_equal oauth_config_response, config
    assert_equal 'https://127.0.0.1.nip.io:8443/oauth/authorize', subject.authorization_endpoint
    assert_equal 'https://127.0.0.1.nip.io:8443/oauth/token', subject.token_endpoint

    assert_requested :get, 'https://localhost:8443/.well-known/oauth-authorization-server', times: 1
  end


  test '#bad_response' do
    stub_request(:get, 'https://localhost:8443/.well-known/oauth-authorization-server').
      to_return(status: 500, body: '')

    2.times do
      assert_nil subject.oauth_configuration # again
    end
    assert_requested :get, 'https://localhost:8443/.well-known/oauth-authorization-server', times: 2
  end

  test 'parse error' do
    stub_request(:get, 'https://localhost:8443/.well-known/oauth-authorization-server').
      to_return(status: 200, body: '{malformed json')

    2.times do
      assert_nil subject.oauth_configuration # again
    end
    assert_requested :get, 'https://localhost:8443/.well-known/oauth-authorization-server', times: 2
    assert_equal 2, subject.config_fetch_retries
  end

  test '#authorization_endpoint' do
    stub_success
    assert_equal 'https://127.0.0.1.nip.io:8443/oauth/authorize', subject.authorization_endpoint
  end

  private

  def stub_success
    stub_request(:get, 'https://localhost:8443/.well-known/oauth-authorization-server').
      to_return(status:200, body: oauth_config_response.to_json)
  end

  def oauth_config_response
    {
      issuer: 'https://127.0.0.1.nip.io:8443',
      authorization_endpoint: 'https://127.0.0.1.nip.io:8443/oauth/authorize',
      token_endpoint: 'https://127.0.0.1.nip.io:8443/oauth/token',
      scopes_supported: [
        'user:check-access',
        'user:full', 'user:info',
        'user:list-projects', 'user:list-scoped-projects'
      ],
      response_types_supported: ['code', 'token'],
      grant_types_supported: ['authorization_code', 'implicit'],
      code_challenge_methods_supported: ['plain', 'S256'],
      userinfo_endpoint: 'https://localhost:8443/apis/user.openshift.io/v1/users/~'
    }
  end
end
