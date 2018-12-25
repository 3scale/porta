require 'test_helper'

class ThreeScale::OAuth2::Auth0ClientTest < ActiveSupport::TestCase

  setup do
    authentication_provider = FactoryBot.build_stubbed(:authentication_provider)
    @authentication = ThreeScale::OAuth2::Client.build_authentication(authentication_provider)
    @oauth2 = ThreeScale::OAuth2::Auth0Client.new(@authentication)
  end

  def test_callback_url
    base_url     = 'http://example.net/auth'
    callback_url = @oauth2.callback_url(base_url)
    assert_equal "#{base_url}/#{@authentication.system_name}/callback", callback_url

    token        = '12345'
    base_url     = 'http://example.net/auth/invitations'
    callback_url = @oauth2.callback_url("#{base_url}/#{token}")
    assert_equal "#{base_url}/auth0/#{@authentication.system_name}/callback?state=#{token}", callback_url
  end

  test '#kind' do
    assert_equal 'auth0', @oauth2.kind
  end

  test '#site' do
    @authentication.options.expects(site: 'http://example.org')
    assert_equal 'http://example.org', @oauth2.site

    @authentication.options.expects(site: nil)
    assert_equal 'http://example.com', @oauth2.site
  end

  test '#user_data' do
    raw_info = {
      'email' => 'foo@example.com',
      'email_verified' => true,
      'nickname' => 'foo',
      'sub' => 'bar|123',
      'user_id' => 'alaska'
    }

    access_token = mock
    access_token.expects(params: {'id_token' => 'my-id_token'})
    @oauth2.stubs(:raw_info).returns(raw_info)
    @oauth2.stubs(:access_token).returns(access_token)

    expected_data = ThreeScale::OAuth2::UserData.new(
      email: 'foo@example.com',
      email_verified: true,
      username: 'foo',
      uid: 'bar|123',
      org_name: nil,
      kind: 'auth0',
      authentication_id: 'alaska',
      id_token: 'my-id_token'
    )

    assert_equal expected_data, @oauth2.user_data
  end
end
