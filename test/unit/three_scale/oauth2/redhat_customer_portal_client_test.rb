# frozen_string_literal: true

require 'test_helper'

class ThreeScale::OAuth2::RedhatCustomerPortalClientTest < ActiveSupport::TestCase
  setup do
    @authentication_provider = FactoryBot.build_stubbed(:authentication_provider)
    @authentication = ThreeScale::OAuth2::Client.build_authentication(@authentication_provider)
    @oauth2 = ThreeScale::OAuth2::RedhatCustomerPortalClient.new(@authentication)
  end

  test '#kind' do
    assert_equal 'redhat_customer_portal', @oauth2.kind
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
    request = mock
    ThreeScale::OAuth2::RedhatCustomerPortalClient::RedirectUri.expects(:call).with(@oauth2, request)
    @oauth2.authenticate_options(request)
  end

  test '#user_data' do
    raw_info = {
      'email' => 'foo@exmaple.com',
      'email_verified' => true,
      'preferred_username' => 'foo',
      'sub' => 'abff123'
    }

    access_token = mock
    access_token.stubs(params: {'id_token' => 'secret-id-token'})
    @oauth2.stubs(:raw_info).returns(raw_info)
    @oauth2.stubs(:access_token).returns(access_token)

    expected_data = {
      email: 'foo@exmaple.com',
      email_verified: true,
      username: 'foo',
      uid: 'abff123',
      org_name: nil,
      kind: 'redhat_customer_portal',
      authentication_id: 'abff123',
      id_token: 'secret-id-token'
    }

    assert_equal expected_data, @oauth2.user_data.to_h
  end

  class RedirectUriTest < ActiveSupport::TestCase

    RedirectUri = ThreeScale::OAuth2::RedhatCustomerPortalClient::RedirectUri

    def test_call_always_redirect_to_master_admin_domain
      authentication_provider = FactoryBot.build_stubbed(:authentication_provider)
      authentication = ThreeScale::OAuth2::Client.build_authentication(authentication_provider)
      oauth2         = ThreeScale::OAuth2::RedhatCustomerPortalClient.new(authentication)

      # TODO: This really looks fishy to me. But it is minor
      # Why do we need to expect reading the scheme if it is not used
      # Example provider will be accessed with HTTP and master with HTTPS
      # The redirect URI does no convey this information at all
      uri = URI('http://example.net/path?plan_id=1&code=12456')
      request = mock('request', scheme: uri.scheme, host: uri.host, params: Rack::Utils.parse_nested_query(uri.query))
      assert_equal "http://#{master_account.admin_domain}/auth/#{authentication_provider.system_name}/callback?plan_id=1&self_domain=example.net", RedirectUri.call(oauth2, request)
    end
  end

  class RedhatCustomerPortalClientTest < ActiveSupport::TestCase
    test 'unsupported flow' do
      authentication_provider = FactoryBot.create(:redhat_customer_portal_authentication_provider, system_name: 'redhat')

      ThreeScale.config.redhat_customer_portal.expects(flow: 'unsupported-fake-flow')

      assert_raise ThreeScale::OAuth2::ClientBase::UnsupportedFlowError do
        ThreeScale::OAuth2::Client.build(authentication_provider)
      end
    end
  end

  class ImplicitFlowTest < ActiveSupport::TestCase
    setup do
      authentication_provider = FactoryBot.create(:keycloak_authentication_provider, system_name: 'redhat')
      @authentication = ThreeScale::OAuth2::Client.build_authentication(authentication_provider)
      @oauth2 = ThreeScale::OAuth2::RedhatCustomerPortalClient::ImplicitFlow.new(@authentication)
    end

    test '#scopes' do
      assert_equal 'openid', @oauth2.scopes
    end

    test '#response_type' do
      assert_equal %w(id_token token), @oauth2.response_type.split
    end

    test '#authorize_url' do
      redirect_uri = URI.encode('http://master-admin.com/auth/redhat/callback?self_domain=alaska-admin.com', Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

      expected_url  = "http://example.com/protocol/openid-connect/auth"
      expected_url += "?client_id=#{@authentication.client_id}"
      expected_url += "&nonce=my-random-nonce"
      expected_url += "&redirect_uri=#{redirect_uri}"
      expected_url += "&response_type=id_token+token"
      expected_url += "&scope=openid"
      expected_url += "&state=keycloak-auth-implicit-flow-3scale"

      base_url = 'http://master-admin.com/auth'
      query_options = {
        self_domain: 'alaska-admin.com',
        state: 'keycloak-auth-implicit-flow-3scale'
      }
      SecureRandom.expects(:hex).returns('my-random-nonce')

      assert_equal expected_url, @oauth2.authorize_url(base_url, query_options)
    end

    test '#authenticate!' do
      request_params = {
        state:               'keycloak-auth-implicit-flow-3scale',
        id_token:            'some-id-token',
        access_token:        'some-access-token',
        token_type:          'bearer',
        session_state:       '9d8d8b2a-2bc0-4d41-83e0-f88efb8026ce',
        expires_in:          900,
        'not-before-policy': 0
      }
      request = mock('request')
      request.expects(:params).at_least_once.returns(request_params)
      request.expects(:session).at_least_once.returns(state: 'keycloak-auth-implicit-flow-3scale')

      access_token = ::OAuth2::AccessToken.from_hash(@oauth2.client, request_params)
      ::OAuth2::AccessToken.expects(:from_kvform).with(@oauth2.client, request_params.to_query).returns(access_token)

      raw_info = {
        'email' => 'foo@exmaple.com',
        'email_verified' => true,
        'preferred_username' => 'foo',
        'sub' => 'abff123'
      }
      @oauth2.expects(:fetch_raw_info).returns(raw_info)

      user_data = ThreeScale::OAuth2::UserData.new({
                                                     email: 'foo@exmaple.com',
                                                     email_verified: true,
                                                     username: 'foo',
                                                     uid: 'abff123',
                                                     org_name: nil,
                                                     kind: 'keycloak',
                                                     authentication_id: 'abff123',
                                                     id_token: nil
                                                   })
      @oauth2.expects(:user_data).returns(user_data)

      @oauth2.authenticate!(nil, request)
    end

    test 'valid state provided' do
      request = mock('request')
      request.expects(:params).at_least_once.returns(state: 'state-to-be-validated')
      request.expects(:session).at_least_once.returns(state: 'state-to-be-validated')

      assert @oauth2.send(:valid_state?, request)
    end

    test 'invalid state provided' do
      request = mock('request', session: {state: 'any-state'})
      @oauth2.expects(:valid_state?).returns(false)
      assert_raises(ThreeScale::OAuth2::RedhatCustomerPortalClient::ImplicitFlow::InvalidParamError) do
        @oauth2.send(:validate_state!, request)
      end
    end

    test '#validate_state! wipes out state from session' do
      request = mock('request')
      request.expects(:params).at_least_once.returns(state: 'state-to-be-validated')
      request.expects(:session).at_least_once.returns(state: 'state-to-be-validated')

      @oauth2.send(:validate_state!, request)

      assert_nil request.session[:state]
    end
  end
end
