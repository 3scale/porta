# frozen_string_literal: true

require 'test_helper'

class ServiceDiscovery::ConfigAndTest < ActiveSupport::TestCase
  def subject
    ThreeScale.config.stubs(service_discovery: config)
    ServiceDiscovery::Config
  end

  test 'config' do
    assert_equal config.object_id, subject.config.object_id
  end

  test 'enabled' do
    assert_equal config.enabled, subject.enabled
  end
  test 'bearer_token' do
    assert_equal config.bearer_token, subject.bearer_token
  end

  test 'client_id' do
    assert_equal config.client_id, subject.client_id
  end

  test 'client_secret' do
    assert_equal config.client_secret, subject.client_secret
  end
  test 'server_scheme' do
    assert_equal config.server_scheme, subject.server_scheme
    config.stubs(server_scheme: nil)
    assert_equal 'https', subject.server_scheme
  end

  test 'server_host' do
    assert_equal config.server_host, subject.server_host
    config.stubs(server_host: nil)
    assert_equal 'openshift.default.svc.cluster.local', subject.server_host
  end

  test 'server_port' do
    assert_equal config.server_port, subject.server_port
    config.stubs(server_port: nil)
    assert_equal 443, subject.server_port
  end

  test 'verify_ssl' do
    assert_equal config.verify_ssl, subject.verify_ssl
    config.stubs(verify_ssl: nil)
    assert_equal OpenSSL::SSL::VERIFY_NONE, subject.verify_ssl
  end

  test 'timeout' do
    assert_equal config.timeout, subject.timeout
    config.stubs(timeout: nil)
    assert_equal 1, subject.timeout
  end

  test 'open_timeout' do
    assert_equal config.open_timeout, subject.open_timeout
    config.stubs(open_timeout: nil)
    assert_equal 1, subject.open_timeout
  end

  test 'max_retry' do
    assert_equal config.max_retry, subject.max_retry
    config.stubs(max_retry: nil)
    assert_equal 5, subject.max_retry
  end

  test 'authentication_method' do
    assert_instance_of ActiveSupport::StringInquirer, subject.authentication_method
    assert_equal config.authentication_method, subject.authentication_method
    config.stubs(authentication_method: nil)
    assert_equal 'service_account', subject.authentication_method
  end

  test 'oauth_server_type' do
    assert_instance_of ActiveSupport::StringInquirer, subject.oauth_server_type
    assert_equal config.oauth_server_type, subject.oauth_server_type
    config.stubs(oauth_server_type: nil)
    assert_equal 'builtin', subject.oauth_server_type
  end

  test 'server_url' do
    assert_equal "#{subject.server_scheme}://#{subject.server_host}:#{subject.server_port}", subject.server_url
  end

  test 'well_known_url' do
    assert_equal "#{subject.server_url}/.well-known/oauth-authorization-server", subject.well_known_url
  end

  test 'verify_ssl?' do
    assert_equal true, subject.verify_ssl?
    config.stubs(verify_ssl: nil)
    assert_equal false, subject.verify_ssl?
  end

  private

  def config
    @config ||= ActiveSupport::OrderedOptions.new.tap do |config|
      config.merge!(
        enabled: false,
        server_scheme: 'http',
        server_port: 8443,
        server_host: 'localhost',
        bearer_token: 'secret-token',
        client_id: '3scale',
        client_secret: 'secret-key',
        authentication_method: 'service_account',
        oauth_server_type: 'oauth',
        timeout: 4,
        open_timeout: 3,
        max_retry: 5,
        verify_ssl: OpenSSL::SSL::VERIFY_PEER
      )
    end
  end
end
