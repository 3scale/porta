# frozen_string_literal: true

require 'test_helper'

class Admin::Api::SettingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    provider = FactoryBot.create(:provider_account)
    host! provider.external_admin_domain
    @token = FactoryBot.create(:access_token, owner: provider.admin_user, scopes: %w[account_management]).plaintext_value
    @settings = provider.settings
  end

  attr_reader :settings, :token

  test 'does not permit cas_server_url even when CAS authentication is active' do
    settings.update_columns(authentication_strategy: 'cas', cas_server_url: 'https://old.example.com')

    put admin_api_settings_path(format: :json), params: { access_token: token, cas_server_url: 'https://new.example.com' }

    assert_response :success
    assert_equal 'https://old.example.com', settings.reload.cas_server_url
  end

  test 'provider key cannot update onprem master plan settings' do
    master = Account.master
    master.settings.account_plans.allow
    master.settings.service_plans.allow
    host! master.external_admin_domain
    ThreeScale.config.stubs(:onpremises).returns(true)
    original = master.settings.attributes.slice('account_plans_ui_visible', 'service_plans_ui_visible',
                                                'change_account_plan_permission', 'change_service_plan_permission')

    put admin_api_settings_path(format: :json), params: {
      provider_key: master.provider_key,
      account_plans_ui_visible: !original['account_plans_ui_visible'],
      service_plans_ui_visible: !original['service_plans_ui_visible'],
      change_account_plan_permission: 'direct', change_service_plan_permission: 'direct'
    }

    assert_response :success
    assert_equal original, master.settings.reload.attributes.slice(*original.keys)
  end

  test 'show' do
    get admin_api_settings_path(access_token: token, format: :json)
    expected_response = {
      settings: {
        useraccountarea_enabled: true,
        signups_enabled: true,
        account_approval_required: false,
        public_search: false,
        account_plans_ui_visible: true,
        change_account_plan_permission: 'request',
        service_plans_ui_visible: true,
        change_service_plan_permission: 'request',
        enforce_sso: false
      }
    }.as_json
    assert_response :success
    assert_equal expected_response, JSON.parse(response.body)
  end

  test 'update' do

    provider = settings.account
    provider.settings.account_plans.allow
    provider.settings.service_plans.allow
    provider.settings.finance.allow

    params = { access_token: token, signups_enabled: false, change_account_plan_permission: 'invalid', change_service_plan_permission: 'invalid'}
    assert_equal 'request', settings.change_account_plan_permission
    assert settings.signups_enabled

    put admin_api_settings_path(format: :json), params: params
    assert_response 422

    errors = JSON.parse(response.body)['errors']
    assert_equal ['is not included in the list'], errors['change_account_plan_permission']
    assert_equal ['is not included in the list'], errors['change_service_plan_permission']

    params['change_account_plan_permission'] = 'direct'
    params['change_service_plan_permission'] = 'none'

    put admin_api_settings_path(format: :json), params: params
    assert_response :success

    settings.reload
    assert_equal 'direct', settings.change_account_plan_permission
    assert_equal 'none', settings.change_service_plan_permission
    assert_not settings.signups_enabled
  end

  [false, true].each do |finance_allowed|
    test "plan change values follow finance availability: #{finance_allowed}" do
      settings.account_plans.allow
      settings.service_plans.allow
      settings.finance.allow if finance_allowed

      %w[request direct credit_card request_credit_card none].each do |value|
        settings.update!(change_account_plan_permission: 'direct', change_service_plan_permission: 'direct')
        put admin_api_settings_path(format: :json), params: {
          access_token: token, change_account_plan_permission: value, change_service_plan_permission: value
        }

        assert_response :success
        expected = finance_allowed || %w[request direct].include?(value) ? value : 'direct'
        settings.reload
        assert_equal expected, settings.change_account_plan_permission
        assert_equal expected, settings.change_service_plan_permission
      end
    end
  end

  test 'update enforce_sso' do
    assert_not settings.enforce_sso

    put admin_api_settings_path(format: :json), params: { access_token: token, enforce_sso: true }

    assert_response :unprocessable_entity, "should not be able to enable enforce_sso if there are no published auth providers"
    error = response.parsed_body['errors']['enforce_sso']
    assert_equal ["Password-based authentication could not be disabled. No published authentication providers."], error

    auth_provider = FactoryBot.create(:self_authentication_provider, account: settings.provider, kind: 'base', published: true)

    put admin_api_settings_path(format: :json), params: { access_token: token, enforce_sso: true }

    assert_response :success, "should be able to enable enforce_sso if there are published auth providers"
    assert response.parsed_body['settings']['enforce_sso']
    assert settings.reload.enforce_sso

    auth_provider.update(published: false)

    put admin_api_settings_path(format: :json), params: { access_token: token, enforce_sso: false }

    assert_response :success, "should be able to disable enforce_sso regardless of published auth providers"
    assert_not response.parsed_body['settings']['enforce_sso']
    assert_not settings.reload.enforce_sso
  end

  test 'rejects hide_service for non-master account' do
    settings.update_column(:hide_service, false)
    put admin_api_settings_path(format: :json), params: { access_token: token, hide_service: true }
    assert_response :success
    assert_not settings.reload.hide_service
  end

  test 'rejects account_plans fields when switch denied' do
    provider = settings.account
    assert provider.settings.switches[:account_plans].denied?
    original_visible = settings.account_plans_ui_visible
    put admin_api_settings_path(format: :json), params: { access_token: token, account_plans_ui_visible: !original_visible, change_account_plan_permission: 'direct' }
    assert_response :success
    settings.reload
    assert_equal original_visible, settings.account_plans_ui_visible
    assert_equal 'request', settings.change_account_plan_permission
  end

  test 'rejects service_plans fields when switch denied' do
    provider = settings.account
    assert provider.settings.switches[:service_plans].denied?
    original_visible = settings.service_plans_ui_visible
    put admin_api_settings_path(format: :json), params: { access_token: token, service_plans_ui_visible: !original_visible, change_service_plan_permission: 'direct' }
    assert_response :success
    settings.reload
    assert_equal original_visible, settings.service_plans_ui_visible
    assert_equal 'request', settings.change_service_plan_permission
  end

  test 'update account_approval_required' do
    assert_not settings.account_approval_required

    put admin_api_settings_path(format: :json), params: { access_token: token, account_approval_required: true }

    assert_response :success
    assert JSON.parse(response.body)['settings']['account_approval_required']
    assert settings.reload.account_approval_required

    put admin_api_settings_path(format: :json), params: { access_token: token, public_search: true }

    assert_response :success
    assert settings.reload.account_approval_required
  end
end
