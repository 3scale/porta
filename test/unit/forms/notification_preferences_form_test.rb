require 'test_helper'

class NotificationPreferencesFormTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.build_stubbed(:simple_provider)
    @user     = FactoryBot.build_stubbed(:simple_user, account: @provider)
  end

  def test_initialize
    form = NotificationPreferencesForm.new(@user, @user.notification_preferences)

    assert form
  end

  def test_authorize_event_abilities
    @user.stubs(:has_permission?).returns(true)

    # there's no required abilities, account_created notification is accessible
    stub_required_abilities({})
    notifications = category_notifications(preferences_form.categories, :account)
    assert notifications.include?('account_created')

    # account_created notification has required abilities
    # stubbed: all abilities are set to false
    Ability.any_instance.expects(:can?).returns(false).at_least_once
    stub_required_abilities({ account_created: [[foo: :bar]] })
    notifications = category_notifications(preferences_form.categories, :account)
    refute notifications.include?('account_created')

    # account_created notification has required abilities
    # stubbed: all abilities are set to true
    Ability.any_instance.expects(:can?).returns(true).at_least_once
    notifications = category_notifications(preferences_form.categories, :account)
    assert notifications.include?('account_created')
  end

  def test_hidden_onprem_multitenancy
    @user.stubs(:has_permission?).returns(true)
    stub_hidden_onprem_multitenancy([])
    notifications = category_notifications(preferences_form.categories, :account)
    assert notifications.include?('account_created')

    stub_hidden_onprem_multitenancy([:account_created])
    notifications = category_notifications(preferences_form.categories, :account)
    assert notifications.include?('account_created')

    ThreeScale.config.stubs(onpremises: true)
    @user.account.master = true
    stub_hidden_onprem_multitenancy([:account_created])
    notifications = category_notifications(preferences_form.categories, :account)
    refute notifications.include?('account_created')
  end

  private

  def stub_hidden_onprem_multitenancy(notifications)
    NotificationPreferencesForm.any_instance
      .expects(:hidden_onprem_multitenancy).returns(notifications).at_least_once
  end

  def stub_required_abilities(abilities)
    NotificationPreferencesForm.any_instance
      .expects(:required_abilities).returns(abilities).at_least_once
  end

  def preferences_form
    NotificationPreferencesForm.new(@user, @user.notification_preferences)
  end

  def find_category_by_key(categories, key)
    categories.find { |c| c.title_key == key }
  end

  def category_notifications(categories, key)
    find_category_by_key(categories, key).notifications
  end
end
