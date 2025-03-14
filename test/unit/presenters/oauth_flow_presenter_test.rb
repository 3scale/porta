require 'test_helper'

class OAuthFlowPresenterTest < ActiveSupport::TestCase

  setup do
    FactoryBot.build_stubbed(:master_account)

    @authentication_provider = FactoryBot.build_stubbed(:authentication_provider, kind: 'auth0')
    @provider = @authentication_provider.account

    env = {
      'HTTP_HOST' => 'example.com',
      'QUERY_STRING' => 'plan_id=42'
    }
    @request = ActionDispatch::TestRequest.create env
    @presenter = OAuthFlowPresenter.new(@authentication_provider, @request)
  end

  def test_sso_integration_callback_url
    @authentication_provider.kind = 'github'
    presenter = OAuthFlowPresenter.new(@authentication_provider, @request)
    assert_equal "http://#{@provider.external_domain}/auth/#{@authentication_provider.system_name}/callback", presenter.sso_integration_callback_url

    @authentication_provider.kind = 'auth0'
    presenter = OAuthFlowPresenter.new(@authentication_provider, @request)
    assert_equal "http://#{@provider.external_domain}/auth/#{@authentication_provider.system_name}/callback, " \
      "http://#{@provider.external_domain}/auth/invitations/auth0/#{@authentication_provider.system_name}/callback",
        presenter.sso_integration_callback_url
  end

  # this is to prevent Internal Server Error for any potential
  # existing SSO integrations with whitespaces in site/realm param
  test 'ignore whitespaces in site param' do
    auth_provider = FactoryBot.build_stubbed(:keycloak_authentication_provider, kind: 'keycloak')
    auth_provider.site = '  http://whitespace-test.com  '

    presenter = OAuthFlowPresenter.new(auth_provider, @request)
    assert presenter.authorize_url.start_with?('http://whitespace-test.com')
  end

  test 'callback_endpoint' do
    expected_url = "http://#{@provider.external_domain}/auth/#{@authentication_provider.system_name}/callback?plan_id=42"
    assert_equal expected_url, @presenter.callback_url
  end

  test 'callback_endpoint with query overriden' do
    expected_url = "http://#{@provider.external_domain}/auth/#{@authentication_provider.system_name}/callback?code=secret"
    assert_equal expected_url, @presenter.callback_url(query: {code: 'secret'})
  end

  test 'authorize_url' do
    uri = URI.parse(@presenter.authorize_url)
    params = CGI.parse(uri.query)

    assert_equal @authentication_provider.client_id, params["client_id"][0]
    assert_equal @presenter.callback_url, params["redirect_uri"][0]
  end

  test 'master callback endpoint' do
    authentication_provider = FactoryBot.build_stubbed(:github_authentication_provider)
    @request.set_header("action_dispatch.request.query_parameters", {})

    presenter = OAuthFlowPresenter.new(authentication_provider, @request)

    expected_url = "http://#{Account.master.external_domain}/master/devportal/auth/#{authentication_provider.system_name}/callback?domain=#{authentication_provider.account.external_domain}"
    assert_equal expected_url, presenter.callback_url
  end

  test 'ssl verification mode' do
    authentication_provider = FactoryBot.build_stubbed(:github_authentication_provider)
    ssl = mock
    ssl.expects(:verify=).with(OpenSSL::SSL::VERIFY_NONE)
    Faraday::Connection.any_instance.stubs(ssl: ssl)
    authentication_provider.stubs(ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)

    @request.set_header("action_dispatch.request.query_parameters", {})
    presenter = OAuthFlowPresenter.new(authentication_provider, @request)
    assert presenter.authorize_url
  end
end
