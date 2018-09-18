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
    preferences = NotificationPreferences.new(enabled_notifications: %w(application_created foo))

    assert_includes preferences.enabled_notifications, 'application_created'
    refute_includes preferences.enabled_notifications, 'foo'

    enabled_notifications = %w(application_created) + hidden_notifications.map(&:to_s)

    assert_equal enabled_notifications, preferences.enabled_notifications

    # kind of Array because formtastic does [obj].flatten
    # see https://github.com/justinfrench/formtastic/blob/8741d76a95b7adf29d39df41f6d4f015cdd74473/lib/formtastic.rb#L1211
    assert_kind_of Array, preferences.enabled_notifications
  end

  test 'enabled_notifications=' do
    preferences = NotificationPreferences.new

    enabled = preferences.enabled_notifications = %w(application_created)
    enabled += hidden_notifications.map(&:to_s)

    assert_equal enabled, preferences.enabled_notifications
    assert_equal preferences.available_notifications, Set.new(preferences.preferences.keys)
  end
end
