# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::CMS::SwitchesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    login! provider
    plan = ApplicationPlan.new(issuer: master_account.first_service!, name: 'enterprise')
    provider.force_upgrade_to_provider_plan!(plan)
  end

  attr_reader :provider

  test 'Finance is globally disabled' do
    ThreeScale.config.stubs(onpremises: false)
    get provider_admin_cms_switches_path
    assert_response :success
    assert_select '#switch-finance-toggle'

    ThreeScale.config.stubs(onpremises: true)
    get provider_admin_cms_switches_path
    assert_response :success
    assert_select '#switch-finance-toggle', true
    assert_select %(table#switches tbody td[data-label="Feature"]), text: 'Finance', count: 1
  end

  test 'update shows the hidden switch' do
    switch_name = provider.hideable_switches.keys.first
    put provider_admin_cms_switch_path(switch_name, format: :js)
    assert_response :success
    assert provider.reload.settings.switches[switch_name].visible?
  end

  test 'destroy hides the visible switch and is a safe no-op if already hidden' do
    @provider.settings.show_account_plans!
    assert @provider.settings.account_plans.visible?

    delete provider_admin_cms_switch_path('account_plans', format: :js)
    assert_response :success
    assert @provider.reload.settings.account_plans.hidden?

    delete provider_admin_cms_switch_path('account_plans', format: :js)
    assert_response :success
    assert @provider.reload.settings.account_plans.hidden?
  end

  test "show a  switch" do
    assert @provider.settings.account_plans.hidden?

    put provider_admin_cms_switch_path('account_plans', format: :js), xhr: true
    assert_response :success

    assert @provider.settings.reload.switches[:account_plans].visible?, 'not visible'
  end
end

