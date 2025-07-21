require 'test_helper'

class NotificationPreferencesTest < ActiveSupport::TestCase

  delegate :hidden_notifications, to: NotificationPreferences

  def test_hidden_preferences
    preferences = NotificationPreferences.new

    assert preferences.include?('csv_data_export')

    preferences.enabled_notifications = ['application_created']

    assert preferences.include?('csv_data_export')
  end

  test 'defaults' do
    preferences = NotificationPreferences.new

    assert_equal [true, false], preferences.preferences.values.uniq
    assert_equal preferences.available_notifications, Set.new(preferences.preferences.keys)
  end

  test 'include?' do
    preferences = NotificationPreferences.new
    preferences.preferences = { 'application_created' => true, 'bar' => false }

    assert_includes preferences, :application_created
    assert_includes preferences, 'application_created'
    refute_includes preferences, :bar
    refute_includes preferences, 'bar'
  end

  test 'self.default_preferences' do
    preferences = NotificationPreferences.new
    default_preferences = NotificationPreferences.default_preferences

    assert_equal preferences.preferences, default_preferences.stringify_keys
  end

  test 'preferences' do
    preferences = NotificationPreferences.new

    assert_equal preferences.default_preferences, preferences.preferences
  end

  test 'preferences=' do
    preferences = NotificationPreferences.new

    preferences.preferences = { foo: true, bar: false }

    assert_equal({ 'foo' => true, 'bar' => false }, preferences.preferences.slice('foo', 'bar'))
  end

  test 'available_notifications' do
    preferences = NotificationPreferences.new
    assert_includes preferences.available_notifications, 'application_created'
  end

  test 'enabled_notifications' do
    preferences = NotificationPreferences.new(enabled_notifications: %w[application_created foo])

    assert_includes preferences.enabled_notifications, 'application_created'
    refute_includes preferences.enabled_notifications, 'foo'

    enabled_notifications = %w[application_created] + hidden_notifications.map(&:to_s)

    assert_same_elements enabled_notifications, preferences.enabled_notifications

    # kind of Array because formtastic does [obj].flatten
    # see https://github.com/justinfrench/formtastic/blob/8741d76a95b7adf29d39df41f6d4f015cdd74473/lib/formtastic.rb#L1211
    assert_kind_of Array, preferences.enabled_notifications
  end

  test 'enabled_notifications=' do
    preferences = NotificationPreferences.new

    enabled = preferences.enabled_notifications = %w[application_created]
    enabled += hidden_notifications.map(&:to_s)

    assert_same_elements enabled, preferences.enabled_notifications
    assert_equal preferences.available_notifications, Set.new(preferences.preferences.keys)
  end

  test 'new_preferences=' do
    preferences = NotificationPreferences.new(enabled_notifications: %w[account_created application_created service_contract_created])

    assert preferences.preferences["application_created"]
    assert_not preferences.preferences["limit_alert_reached_provider"]

    before_change = preferences.preferences.except("application_created", "limit_alert_reached_provider")

    preferences.new_preferences = { application_created: false, limit_alert_reached_provider: true }

    assert_not preferences.preferences["application_created"]
    assert preferences.preferences["limit_alert_reached_provider"]

    # the notifications that were not updated by #new_preferences= have not been changed
    assert_equal before_change, preferences.preferences.except("application_created", "limit_alert_reached_provider")

    # process string values correctly
    preferences.new_preferences = { "plan_downgraded" => "true", "service_contract_created" => "false" }

    assert_not preferences.preferences["service_contract_created"]
    assert preferences.preferences["plan_downgraded"]
  end

  test 'new_preferences= invalid values' do
    preferences = FactoryBot.create(:user_with_account).notification_preferences
    preferences.save

    preferences.new_preferences = { non_existing_preference: true }

    assert_not preferences.valid?
    assert_equal ["notification 'non_existing_preference' is not valid"], preferences.errors[:preferences]

    preferences.reload
    new_prefs = { account_created: "asdf", application_created: "", service_contract_created: 1 }
    preferences.new_preferences = new_prefs

    assert_not preferences.valid?
    errors = preferences.errors[:preferences]
    assert_equal 3, errors.size
    new_prefs.each_key do |key|
      errors.include?("invalid value for '#{key}', must be either true or false")
    end
  end
end
