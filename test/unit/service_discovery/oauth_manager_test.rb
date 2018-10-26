# frozen_string_literal: true

require 'test_helper'

class ServiceDiscovery::OAuthManagerTest < ActiveSupport::TestCase
  test '#access_token with service_account' do
    config.stubs(enabled: true, authentication_method: 'service_account', bearer_token: 'bearer-token')
    oauth_manager = ServiceDiscovery::OAuthManager.new
    assert_equal 'bearer-token', oauth_manager.access_token

    user = User.new
    oauth_manager = ServiceDiscovery::OAuthManager.new(user)
    assert_equal 'bearer-token', oauth_manager.access_token
  end

  test '#service_usable?' do
    oauth_manager = ServiceDiscovery::OAuthManager.new
    oauth_manager.stubs(access_token: nil)
    refute oauth_manager.service_usable?

    oauth_manager.stubs(access_token: 'something')
    assert oauth_manager.service_usable?
  end

  test '#access_token with oauth' do
    config.stubs(enabled: true, authentication_method: 'oauth', bearer_token: 'bearer-token')
    user = User.new
    oauth_manager = ServiceDiscovery::OAuthManager.new(user)
    ServiceDiscovery::OAuthConfiguration.instance.stubs(service_accessible?: true)

    token = Object.new
    token.stubs(value: 'my-token')
    provided_access_tokens = Object.new
    valid = Object.new
    provided_access_tokens.stubs(valid: valid)
    valid.stubs(first: token)
    user.stubs(provided_access_tokens: provided_access_tokens)
    assert_equal 'my-token', oauth_manager.access_token

    valid.stubs(first: nil)
    assert_nil oauth_manager.access_token

    oauth_manager.stubs(service_accessible?: false)
    valid.stubs(first: token)
    assert_nil oauth_manager.access_token

    valid.stubs(first: nil)
    assert_nil oauth_manager.access_token
  end

  private

  def config
    ThreeScale.config.service_discovery
  end
end
