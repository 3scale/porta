# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @org_name = 'Company'
    provider = FactoryBot.create(:provider_account, org_name: @org_name)
    user = FactoryBot.create(:admin, account: provider)
    user.activate!
    login!(provider, user: user)
  end

  test 'products and backends widgets' do
    xpath_selector = './/section[@id="apis"]'
    element_text = 'APIs'

    User.any_instance.stubs(:access_to_service_admin_sections?).returns(true)
    get provider_admin_dashboard_path
    assert_xpath(xpath_selector, element_text)
  end

  test 'products and backends widgets no access' do
    xpath_selector = './/section[@id="apis"]'
    element_text = "You don't have access to any API on the #{@org_name} account. Please contact #{@org_name} to request access."

    User.any_instance.stubs(:access_to_service_admin_sections?).returns(false)
    get provider_admin_dashboard_path
    assert_xpath(xpath_selector, element_text)
  end
end
