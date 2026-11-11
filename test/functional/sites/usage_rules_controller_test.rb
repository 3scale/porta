require 'test_helper'

class Sites::UsageRulesControllerTest < ActionController::TestCase

  def setup
    @provider  = FactoryBot.create(:provider_account)
    request.host = @provider.external_admin_domain
    login_as(@provider.admins.first)
    @settings = @provider.settings
  end

  test 'onprem master cannot see or update plan settings even when switches are allowed' do
    master = Account.master
    master.settings.account_plans.allow
    master.settings.service_plans.allow
    request.host = master.external_admin_domain
    login_as(master.admins.first)
    ThreeScale.config.stubs(:onpremises).returns(true)

    get :edit

    assert_response :success
    assert_select 'input#settings_account_plans_ui_visible', count: 0
    assert_select 'input#settings_service_plans_ui_visible', count: 0

    original = master.settings.attributes.slice('account_plans_ui_visible', 'service_plans_ui_visible',
                                                'change_account_plan_permission', 'change_service_plan_permission')
    put :update, params: { settings: {
      account_plans_ui_visible: !original['account_plans_ui_visible'],
      service_plans_ui_visible: !original['service_plans_ui_visible'],
      change_account_plan_permission: 'direct', change_service_plan_permission: 'direct'
    } }

    assert_response :redirect
    assert_equal original, master.settings.reload.attributes.slice(*original.keys)
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
    @provider.settings.account_plans.allow
    put :update, params: { settings: { change_account_plan_permission: 'invalid_value' } }

    assert_response :success
    assert_template :edit
  end

  test 'renders correct checked state for change_account_plan_permission' do
    @provider.settings.account_plans.allow
    @settings.update!(change_account_plan_permission: 'direct')

    get :edit

    assert_response :success
    assert_select "input[name='settings[change_account_plan_permission]'][value='direct'][checked='checked']", count: 1
  end

  test 'renders correct checked state for change_service_plan_permission' do
    @provider.settings.service_plans.allow
    @settings.update!(change_service_plan_permission: 'direct')

    get :edit

    assert_response :success
    assert_select "input[name='settings[change_service_plan_permission]'][value='direct'][checked='checked']", count: 1
  end

  test 'rejects hide_service when not master account' do
    assert_not @provider.master?
    @settings.update_column(:hide_service, false)
    put :update, params: { settings: { hide_service: true } }
    assert_response :redirect
    assert_not @settings.reload.hide_service
  end

  test 'accepts hide_service for SaaS master' do
    master = Account.master
    request.host = master.external_admin_domain
    login_as(master.admins.first)
    master.settings.update_column(:hide_service, false)

    put :update, params: { settings: { hide_service: true } }
    assert_response :redirect
    assert master.settings.reload.hide_service
  end

  test 'rejects hide_service for on-premises master' do
    master = Account.master
    request.host = master.external_admin_domain
    login_as(master.admins.first)
    ThreeScale.config.stubs(:onpremises).returns(true)
    master.settings.update_column(:hide_service, false)

    put :update, params: { settings: { hide_service: true } }
    assert_response :redirect
    assert_not master.settings.reload.hide_service
  end

  test 'rejects cas_server_url when auth strategy is not CAS' do
    assert_not @settings.authentication_strategy.cas?
    @settings.update_column(:cas_server_url, 'https://old.example.com')
    put :update, params: { settings: { cas_server_url: 'https://new.example.com' } }
    assert_response :redirect
    assert_equal 'https://old.example.com', @settings.reload.cas_server_url
  end

  test 'accepts cas_server_url when auth strategy is CAS' do
    @settings.update_column(:authentication_strategy, 'cas')
    put :update, params: { settings: { cas_server_url: 'https://cas.example.com' } }
    assert_response :redirect
    assert_equal 'https://cas.example.com', @settings.reload.cas_server_url
  end

  test 'rejects account_plans fields when switch denied' do
    assert @settings.switches[:account_plans].denied?
    original = @settings.account_plans_ui_visible
    put :update, params: { settings: { account_plans_ui_visible: !original, change_account_plan_permission: 'direct' } }
    @settings.reload
    assert_equal original, @settings.account_plans_ui_visible
    assert_equal 'request', @settings.change_account_plan_permission
  end

  test 'accepts account_plans fields when switch allowed' do
    @provider.settings.account_plans.allow
    put :update, params: { settings: { account_plans_ui_visible: false, change_account_plan_permission: 'direct' } }
    @settings.reload
    assert_not @settings.account_plans_ui_visible
    assert_equal 'direct', @settings.change_account_plan_permission
  end

  test 'rejects service_plans fields when switch denied' do
    assert @settings.switches[:service_plans].denied?
    original = @settings.service_plans_ui_visible
    put :update, params: { settings: { service_plans_ui_visible: !original, change_service_plan_permission: 'direct' } }
    @settings.reload
    assert_equal original, @settings.service_plans_ui_visible
    assert_equal 'request', @settings.change_service_plan_permission
  end

  test 'accepts service_plans fields when switch allowed' do
    @provider.settings.service_plans.allow
    put :update, params: { settings: { service_plans_ui_visible: false, change_service_plan_permission: 'direct' } }
    @settings.reload
    assert_not @settings.service_plans_ui_visible
    assert_equal 'direct', @settings.change_service_plan_permission
  end

  [false, true].each do |finance_allowed|
    test "plan change values follow finance availability: #{finance_allowed}" do
      @settings.account_plans.allow
      @settings.service_plans.allow
      @settings.finance.allow if finance_allowed

      %w[request direct credit_card request_credit_card none].each do |value|
        @settings.update!(change_account_plan_permission: 'direct', change_service_plan_permission: 'direct')
        put :update, params: { settings: { change_account_plan_permission: value, change_service_plan_permission: value } }

        assert_redirected_to admin_site_settings_url
        expected = finance_allowed || %w[request direct].include?(value) ? value : 'direct'
        @settings.reload
        assert_equal expected, @settings.change_account_plan_permission
        assert_equal expected, @settings.change_service_plan_permission
      end
    end
  end

  test 'update with valid params' do
    @provider.settings.account_plans.allow
    @provider.settings.service_plans.allow
    @provider.settings.finance.allow
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
