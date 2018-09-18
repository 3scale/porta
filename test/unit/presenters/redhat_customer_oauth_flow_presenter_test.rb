require 'test_helper'

class RedhatCustomerOAuthFlowPresenterTest < ActiveSupport::TestCase
  def setup
    provider_account = FactoryGirl.create(:simple_provider, provider_account: master_account, self_domain: 'admin.company.com', domain: 'company.com')

    query_params = { plan_id: 52 }
    host = provider_account.self_domain
    url = url_helpers.provider_admin_account_path(provider_account, query_params)
    @request = stubs(:request)
    @request.stubs(scheme: 'http', host: host, query_parameters: query_params, params: query_params)

    @redhat_customer_oauth_flow_presenter = RedhatCustomerOAuthFlowPresenter.new(provider_account, @request)
  end

  def test_callback_url
    system_name = RedhatCustomerPortalSupport::RH_CUSTOMER_PORTAL_SYSTEM_NAME
    assert_equal "http://#{master_account.admin_domain}/auth/#{system_name}/callback?plan_id=52&self_domain=admin.company.com", @redhat_customer_oauth_flow_presenter.callback_url
  end

  def test_domain_parameters
    expected_result = { self_domain: 'admin.company.com' }
    assert_equal expected_result, @redhat_customer_oauth_flow_presenter.send(:domain_parameters)
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
