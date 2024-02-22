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
        strong_passwords_enabled: false,
        public_search: false,
        account_plans_ui_visible: true,
        change_account_plan_permission: 'request',
        service_plans_ui_visible: true,
        change_service_plan_permission: 'request'
      }
    }.as_json
    assert_response :success
    assert_equal expected_response, JSON.parse(response.body)
  end

  test 'update' do
    params = { access_token: token, signups_enabled: false, change_account_plan_permission: 'invalid' }
    assert 'request', settings.change_account_plan_permission
    assert settings.signups_enabled

    put admin_api_settings_path(format: :json), params: params
    assert_response 422

    params['change_account_plan_permission'] = 'direct'

    put admin_api_settings_path(format: :json), params: params
    assert_response :success

    assert 'direct', settings.reload.change_account_plan_permission
    assert_not settings.signups_enabled
  end

  test 'update account_approval_required' do
    assert_not settings.account_approval_required

    put admin_api_settings_path(format: :json), params: { access_token: token, account_approval_required: true }

    assert_response :success
    assert JSON.parse(response.body)['settings']['account_approval_required']

    assert settings.reload.account_approval_required
  end
end
