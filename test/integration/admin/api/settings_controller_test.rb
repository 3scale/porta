# frozen_string_literal: true

require 'test_helper'

class Admin::Api::SettingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    provider = FactoryBot.create(:provider_account)
    host! provider.external_admin_domain
    @token = FactoryBot.create(:access_token, owner: provider.admin_user, scopes: %w[account_management]).value
    @settings = provider.settings
  end

  attr_reader :settings, :token

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
