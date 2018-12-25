require 'test_helper'

class Sites::UsageRulesControllerTest < ActionController::TestCase

  def setup
    @provider  = FactoryBot.create(:provider_account)
    request.host = @provider.admin_domain
    login_as(@provider.admins.first)
    @settings = @provider.settings
  end

  test 'show checkbox if 1 account plan' do
    get :edit
    assert_response :success
    assert_select 'title', 'Usage Rules | Red Hat 3scale API Management'
    assert_select 'input#settings_account_approval_required'
    assert_select 'p.inline-hints', 'Approval is required by you before developer accounts are activated.'
  end

  test 'ingnore custom plans' do
    FactoryBot.create(:account_plan, issuer: @provider, original_id: 1)
    get :edit
    assert_select 'input#settings_account_approval_required'
    assert_select 'p.inline-hints', 'Approval is required by you before developer accounts are activated.'
  end

  test 'hide checkbox for multiple account plans with ui hidden' do
    FactoryBot.create(:account_plan, issuer: @provider)
    @settings.account_plans_ui_visible = false
    @settings.save
    get :edit
    assert_select 'input#settings_account_approval_required', false, 'No checkbox when multiple plans but hidden ui'
  end

  test 'defer to account plan when multiple account plans and ui visible' do
    FactoryBot.create(:account_plan, issuer: @provider)
    get :edit
    assert_select 'input#settings_account_approval_required'
    assert_select 'p.inline-hints', 'Set per account plan from Account Plans.'
  end
end
