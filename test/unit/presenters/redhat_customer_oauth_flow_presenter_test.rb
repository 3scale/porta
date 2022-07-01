require 'test_helper'

class RedhatCustomerOAuthFlowPresenterTest < ActiveSupport::TestCase
  def setup
    provider_account = FactoryBot.create(:simple_provider, provider_account: master_account, self_domain: 'admin.company.com', domain: 'company.com')

    query_params = { plan_id: 52 }
    host = provider_account.internal_admin_domain
    @request = ActionDispatch::TestRequest.create(
      'HTTP_HOST' => host,
      "action_dispatch.request.parameters" => query_params,
      "action_dispatch.request.query_parameters" => query_params
    )

    @redhat_customer_oauth_flow_presenter = RedhatCustomerOAuthFlowPresenter.new(provider_account, @request)
  end

  def test_callback_url
    system_name = RedhatCustomerPortalSupport::RH_CUSTOMER_PORTAL_SYSTEM_NAME
    assert_equal "http://#{master_account.internal_admin_domain}/auth/#{system_name}/callback?plan_id=52&self_domain=admin.company.com", @redhat_customer_oauth_flow_presenter.callback_url
  end

  def test_domain_parameters
    expected_result = { self_domain: 'admin.company.com' }
    assert_equal expected_result, @redhat_customer_oauth_flow_presenter.send(:domain_parameters)
  end

  def url_helpers
    System::UrlHelpers.system_url_helpers
  end
end
