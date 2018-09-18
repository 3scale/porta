# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::WebhooksControllerTest < ActionDispatch::IntegrationTest

  setup do
    login! master_account
  end

  test 'GET new shows or not account_plan_changed depending on onpremises value' do
    xpath_selector = './/li[@id="web_hook_account_plan_changed_on_input"]'
    element_text = 'Account Plan changed'

    # Saas
    ThreeScale.config.stubs(onpremises: false)
    get new_provider_admin_webhooks_path
    assert_xpath(xpath_selector, element_text)

    # On premises
    ThreeScale.config.stubs(onpremises: true)
    get new_provider_admin_webhooks_path
    refute_xpath(xpath_selector, element_text)
  end

end
