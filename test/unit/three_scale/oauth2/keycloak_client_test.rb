# frozen_string_literal: true

require 'test_helper'

class ThreeScale::OAuth2::KeycloakClientTest < ActiveSupport::TestCase
  setup do
    authentication_provider = FactoryGirl.build_stubbed(:authentication_provider)
    @authentication = ThreeScale::OAuth2::Client.build_authentication(authentication_provider)
    @oauth2 = ThreeScale::OAuth2::KeycloakClient.new(@authentication)
  end

  test '#kind' do
    assert_equal 'keycloak', @oauth2.kind
  end

  test '#realm' do
    @authentication.options.expects(site: 'http://example.net')
    assert_equal 'http://example.net', @oauth2.realm

    @authentication.options.expects(site: nil)

    assert_raises ThreeScale::OAuth2::KeycloakClient::MissingRealmError do
      assert_nil @oauth2.realm
    end
  end

  test '#authenticate_options' do
    request = mock('request', url: 'http://example.com/path?foo=bar&code=123456', real_host: 'example.net')

    options = @oauth2.authenticate_options(request)

    assert_equal({ redirect_uri: 'http://example.net/path?foo=bar' }, options)
  end

  test '#user_data' do
    raw_info = {
      'email' => 'foo@example.com',
      'email_verified' => true,
      'preferred_username' => 'foo',
      'sub' => 'abff123'
    }

    access_token = mock
    access_token.stubs(params: {'id_token' => 'secret-id-token'})
    @oauth2.stubs(:raw_info).returns(raw_info)
    @oauth2.stubs(:access_token).returns(access_token)

    expected_data = {
      email: 'foo@example.com',
      email_verified: true,
      username: 'foo',
      uid: 'abff123',
      org_name: nil,
      kind: 'keycloak',
      authentication_id: 'abff123',
      id_token: 'secret-id-token'
    }

    assert_equal expected_data, @oauth2.user_data.to_h
  end

  class RedirectUriTest < ActiveSupport::TestCase

    RedirectUri = ThreeScale::OAuth2::KeycloakClient::RedirectUri

    def setup
      authentication_provider = FactoryGirl.build_stubbed(:authentication_provider)
      authentication = ThreeScale::OAuth2::Client.build_authentication(authentication_provider)
      @oauth2        = ThreeScale::OAuth2::KeycloakClient.new(authentication)
    end

    def test_call
      request = mock('request', url: 'http://example.net/path?plan_id=1', host: 'example.net')
      assert_equal 'http://example.net/path?plan_id=1', RedirectUri.call(request)

      query   = { RedirectUri::NOT_ALLOWED_PARAMS.first => 1 }.to_query
      request = mock('request', url: "http://example.net/path?#{query}", host: 'example.net')
      assert_equal 'http://example.net/path', RedirectUri.call(request)
    end
  end
end
