require 'test_helper'

class OAuthFlowPresenterTest < ActiveSupport::TestCase

  setup do
    FactoryGirl.build_stubbed(:master_account)

    @authentication_provider = FactoryGirl.build_stubbed(:authentication_provider, kind: 'auth0')
    @provider = @authentication_provider.account

    @request = stubs(:request)
    @request.stubs(scheme: 'http', domain: 'example.com', query_parameters: {'plan_id' => 42})
    @presenter = OauthFlowPresenter.new(@authentication_provider, @request)
  end

  def test_sso_integration_callback_url
    @authentication_provider.kind = 'github'
    presenter = OauthFlowPresenter.new(@authentication_provider, @request)
    assert_equal "http://#{@provider.domain}/auth/#{@authentication_provider.system_name}/callback", presenter.sso_integration_callback_url

    @authentication_provider.kind = 'auth0'
    presenter = OauthFlowPresenter.new(@authentication_provider, @request)
    assert_equal "http://#{@provider.domain}/auth/#{@authentication_provider.system_name}/callback, " \
      "http://#{@provider.domain}/auth/invitations/auth0/#{@authentication_provider.system_name}/callback",
        presenter.sso_integration_callback_url
  end

  test 'callback_endpoint' do
    expected_url = "http://#{@provider.domain}/auth/#{@authentication_provider.system_name}/callback?plan_id=42"
    assert_equal expected_url, @presenter.callback_url
  end

  test 'callback_endpoint with query overriden' do
    expected_url = "http://#{@provider.domain}/auth/#{@authentication_provider.system_name}/callback?code=secret"
    assert_equal expected_url, @presenter.callback_url(query: {code: 'secret'})
  end

  test 'authorize_url' do
    uri = URI.parse(@presenter.authorize_url)
    params = CGI.parse(uri.query)

    assert_equal @authentication_provider.client_id, params["client_id"][0]
    assert_equal @presenter.callback_url, params["redirect_uri"][0]
  end

  test 'master callback endpoint' do
    authentication_provider = FactoryGirl.build_stubbed(:github_authentication_provider)

    presenter = OauthFlowPresenter.new(authentication_provider, mock('request', scheme: 'http', query_parameters: {}))

    expected_url = "http://#{Account.master.domain}/master/devportal/auth/#{authentication_provider.system_name}/callback?domain=#{authentication_provider.account.domain}"
    assert_equal expected_url, presenter.callback_url
  end

  test 'ssl verification mode' do
    authentication_provider = FactoryGirl.build_stubbed(:github_authentication_provider)
    ssl = mock
    ssl.expects(:verify=).with(OpenSSL::SSL::VERIFY_NONE)
    Faraday::Connection.any_instance.stubs(ssl: ssl)
    authentication_provider.stubs(ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)
    presenter = OauthFlowPresenter.new(authentication_provider, mock('request', scheme: 'http', query_parameters: {}))
    assert presenter.authorize_url
  end
end
