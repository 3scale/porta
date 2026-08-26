require 'test_helper'

class Sites::UsageRulesControllerTest < ActionController::TestCase

  def setup
    @provider  = FactoryBot.create(:provider_account)
    request.host = @provider.external_admin_domain
    login_as(@provider.admins.first)
    @settings = @provider.settings
  end

  test 'show checkbox if 1 account plan' do
    get :edit
    assert_response :success
    assert_select 'title', 'Usage Rules | Red Hat 3scale API Management'
    assert_select 'input#settings_account_approval_required'
    assert_select '.pf-c-check__description', 'Approval is required by you before developer accounts are activated.'
  end

  test 'ingnore custom plans' do
    FactoryBot.create(:account_plan, issuer: @provider, original_id: 1)
    get :edit
    assert_select 'input#settings_account_approval_required'
    assert_select '.pf-c-check__description', 'Approval is required by you before developer accounts are activated.'
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
    assert_select '.pf-c-check__description', 'Set per account plan from Account Plans.'
  end

  test 'update with invalid params' do
    put :update, params: { settings: { change_account_plan_permission: 'invalid_value' } }

    assert_response :success
    assert_template :edit
  end

  test 'update with valid params' do
    @settings.update(strong_passwords_enabled: true, public_search: true)
    %i[useraccountarea_enabled signups_enabled public_search
       account_plans_ui_visible service_plans_ui_visible].each do |setting|
      assert @settings.send(setting), "#{setting} setting is not true as expected"
    end

    assert_equal "request", @settings.change_account_plan_permission
    assert_equal "request", @settings.change_service_plan_permission

    put :update, params: {
      settings: {
        useraccountarea_enabled: '0',
        signups_enabled: '0',
        public_search: '0',
        account_plans_ui_visible: '0',
        service_plans_ui_visible: '0',
        change_account_plan_permission: 'credit_card',
        change_service_plan_permission: 'credit_card'
      }
    }

    assert_redirected_to admin_site_settings_url
    assert_equal "Settings updated", flash[:success]

    @settings.reload

    %i[useraccountarea_enabled signups_enabled
       account_plans_ui_visible service_plans_ui_visible
       hide_service public_search].each do |setting|
      assert_not @settings.send(setting), "#{setting} setting is not false as expected"
    end
    assert_equal "credit_card", @settings.change_account_plan_permission
    assert_equal "credit_card", @settings.change_service_plan_permission
  end
end
