require 'test_helper'

class ProviderOAuthFlowPresenterTest < ActiveSupport::TestCase

  setup do
    provider = FactoryGirl.build_stubbed(:simple_provider, self_domain: 'example.com')
    authentication_provider = AuthenticationProvider::Auth0.new(account: provider, kind: 'auth0', system_name: 'auth0_abc123')

    request = stubs(:request)
    request.stubs(scheme: 'http')
    @presenter = ProviderOauthFlowPresenter.new(authentication_provider, request, provider.self_domain)
  end

  def test_human_kind
    assert_equal 'Auth0', @presenter.human_kind
  end

  def test_kind
    assert_equal 'auth0', @presenter.kind
  end

  test 'test_flow_callback_url' do
    assert_equal "http://example.com/p/admin/account/callback/auth0_abc123", @presenter.test_flow_callback_url
  end
end
