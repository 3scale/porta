# frozen_string_literal: true

require 'test_helper'

class Admin::Api::Personal::NotificationPreferencesControllerTest < ActionDispatch::IntegrationTest
  def setup
    provider = FactoryBot.create(:provider_account)
    @user = provider.admin_users.first!
    @token = FactoryBot.create(:access_token, owner: @user, scopes: %w[account_management]).value
    host! provider.external_admin_domain
  end

  attr_reader :user, :token

  test 'index' do
    get admin_api_personal_notification_preferences_path(format: :json, access_token: @token)

    prefs =  JSON.parse(response.body)['notification_preferences']

    assert_response :success
    assert_same_elements NotificationPreferences.available_notifications, prefs.keys.map(&:to_sym)
    assert prefs.values.all? { [true, false].include?(_1) }
  end

  test 'update successfully' do
    update_params = {
      application_created: false,
      account_created: false,
      weekly_report: true,
      daily_report: true
    }
    put admin_api_personal_notification_preferences_path(format: :json), params: { access_token: token, **update_params }

    prefs =  JSON.parse(response.body)['notification_preferences']

    assert_response :success
    user.notification_preferences.reload
    update_params.each_pair do |key, value|
      assert_equal value, prefs[key.to_s], "Notification '#{key}' should be set to '#{value}'"
      assert_equal value, user.notification_preferences.include?(key.to_s)
    end
  end

  test 'update with wrong parameters' do
    user.notification_preferences.update(enabled_notifications: ['account_created'])
    previous_prefs = user.notification_preferences.preferences
    update_params = {
      non_existing_notification: false,
      account_created: 'some-value'
    }
    put admin_api_personal_notification_preferences_path(format: :json), params: { access_token: token, **update_params }

    assert_response :success
    assert_equal previous_prefs, user.notification_preferences.reload.preferences
  end
end
