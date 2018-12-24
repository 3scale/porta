require 'test_helper'

class Provider::Admin::User::NotificationPreferencesControllerTest < ActionController::TestCase

  delegate :hidden_notifications, to: NotificationPreferences

  setup do
    @provider = FactoryBot.create(:provider_account)
    @hidden   = NotificationMailer.hidden_notifications
    @visible  = NotificationMailer.event_mapping.keys - @hidden

    login_provider(@provider)
  end

  test 'should get list of notification preferences' do
    NotificationPreferencesForm.any_instance.expects(:enabled?).returns(true).at_least_once

    get :show
    assert_response :success

    @visible.each do |method|
      assert_select input_preference_selector(method), count: 1 do |input|
        attributes = input.first.attributes
        assert_equal 'notification_preferences[enabled_notifications][]', attributes['name'].value
      end
    end

    @hidden.each do |method|
      assert_select input_preference_selector(method), count: 0
    end

    assert_select 'form.notification_preferences' do
      assert_select 'input[type="checkbox"]', count: @visible.size
    end
  end

  test 'should update list of notification preferences' do
    patch :update, notification_preferences: { enabled_notifications: %w[application_created] }
    assert_response :redirect
    assert_redirected_to action: :show
  end

  test 'should create list of notification preferences' do
    NotificationPreferences.delete_all

    assert_difference NotificationPreferences.method(:count) do
      patch :update, notification_preferences: { enabled_notifications: %w[application_created] }
      assert_response :redirect
      assert_redirected_to action: :show
    end

    preferences = NotificationPreferences.last!
    enabled     = %w[application_created] + hidden_notifications.map(&:to_s)

    assert_equal enabled, preferences.enabled_notifications.to_a
  end

  test 'should return 400 on missing params' do
    patch :update
    assert_response :bad_request
  end

  private

  def input_preference_selector(name)
    "input#notification_preferences_enabled_notifications_#{name}[value='#{name}']"
  end
end
