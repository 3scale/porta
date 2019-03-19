require 'test_helper'

class Notifications::NewNotificationSystemMigrationTest < ActiveSupport::TestCase
  Migration = Notifications::NewNotificationSystemMigration

  def setup
    @account   = FactoryBot.create(:simple_provider)
    @user      = FactoryBot.create(:simple_user, account: @account)
    @migration = Migration.new(@account)

    assert @account.users.count > 0, 'account has to have at least 1 user'
  end

  def test_notification_preferences
    default_preferences = NotificationPreferences.default_preferences

    assert_equal default_preferences, @migration.notification_preferences

    set_mail_dispatch_rule!('key_deleted', enabled: true) # does not have mapping yet
    assert_equal default_preferences, @migration.notification_preferences

    expected = { account_created: false }

    set_mail_dispatch_rule!('user_signup', enabled: false)
    assert_equal default_preferences.merge(expected), @migration.notification_preferences

    expected[:message_received] = true

    set_mail_dispatch_rule!('new_message', enabled: true)
    assert_equal default_preferences.merge(expected), @migration.notification_preferences
  end

  def test_enabled?
    assert @migration.enabled?

    @account.expects(:provider_can_use?).with(:new_notification_system).returns(false)

    refute @migration.enabled?

    refute Migration.new(FactoryBot.build_stubbed(:simple_buyer)).enabled?
  end

  def test_dispatch?
    weekly_reports = SystemOperation.for(:key_deleted)
    assert @migration.dispatch?(weekly_reports)

    user_signup = SystemOperation.for(:user_signup)
    refute @migration.dispatch?(user_signup)
  end

  def test_run!
    @user.notification_preferences.update_attributes!(preferences: {})
    MailDispatchRule.delete_all
    enabled_dispatch_rules = @account.mail_dispatch_rules.enabled

    assert_equal 0, enabled_dispatch_rules.count

    user_notification_preferences = @user.notification_preferences
    new_notification_preferences = @migration.notification_preferences.stringify_keys
    new_enabled_notifications = user_notification_preferences.available_notifications & new_notification_preferences.select { |_, v| v }.keys

    Migration.run!(@account)

    assert_equal new_notification_preferences, user_notification_preferences.reload.preferences
    assert_same_elements new_enabled_notifications, enabled_notifications

    set_mail_dispatch_rule!('user_signup', enabled: true)
    assert_equal 5, enabled_dispatch_rules.count

    Migration.run!(@account)

    assert_equal 4, enabled_dispatch_rules.count
    assert_contains enabled_notifications, 'account_created'

    set_mail_dispatch_rule!('limit_alerts', enabled: true)
    assert_equal 5, enabled_dispatch_rules.count

    Migration.run!(@account)

    assert_equal 4, enabled_dispatch_rules.count
    assert_contains enabled_notifications, 'limit_alert_reached_provider'
    assert_contains enabled_notifications, 'limit_violation_reached_provider'

    set_mail_dispatch_rule!('weekly_reports', enabled: true) # not yet migrated to user level

    Migration.run!(@account)

    assert_equal 4, enabled_dispatch_rules.count
  end

  private

  def enabled_notifications
    @user.reload.notification_preferences.enabled_notifications
  end

  def available_notifications
    NotificationMailer.event_mapping
  end

  def set_mail_dispatch_rule!(ref, enabled: true)
    operation = SystemOperation.find_by_ref(ref)
    rule = @account.mail_dispatch_rules.find_or_create_by(system_operation: operation)
    rule.update_attributes!(dispatch: enabled)
  end
end
