require 'test_helper'

class NotificationPreferencesFormTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.build_stubbed(:simple_provider)
    buyer     = FactoryBot.build_stubbed(:simple_buyer, provider_account: @provider)
    @user     = FactoryBot.build_stubbed(:simple_user, account: buyer) end

  def test_initialize
    form = NotificationPreferencesForm.new(@user, @user.notification_preferences)

    assert form
  end

  def test_categories_billing
    @provider.stubs(:is_billing_buyers?).returns(true)
    @user.expects(:has_permission?).returns(false).at_least_once
    @user.expects(:has_permission?).with(:finance).returns(true).at_least_once
    stubs_at_least_one_service?(true)

    # user has permission to billing
    # provider is billing his buyers
    assert_category_present preferences_form.categories, :billing

    ThreeScale.config.stubs(onpremises: true)
    @provider.stubs(master?: true)
    refute_category_present preferences_form.categories, :billing
    ThreeScale.config.stubs(onpremises: false)
    @provider.unstub(:master?)

    @user.expects(:has_permission?).with(:finance).returns(false).at_least_once

    # user doesn't have permission to billing
    # provider is billing his buyers
    refute_category_present preferences_form.categories, :billing

    @user.expects(:has_permission?).with(:finance).returns(true).at_least_once

    # user has permission to billing
    # provider is billing his buyers
    assert_category_present preferences_form.categories, :billing

    @provider.expects(:is_billing_buyers?).returns(false).at_least_once

    # user has permission to billing
    # provider is not billing his buyers
    refute_category_present preferences_form.categories, :billing
  end

  def test_categories_account
    @user.expects(:has_permission?).returns(false).at_least_once
    @user.expects(:has_permission?).with(:partners).returns(true).at_least_once

    # user has permission to partners
    assert_category_present preferences_form.categories, :account

    @user.expects(:has_permission?).with(:partners).returns(false).once

    # user doesn't have permission to partners
    refute_category_present preferences_form.categories, :account
  end

  def test_categories_application
    @user.expects(:has_permission?).returns(false).at_least_once
    @user.expects(:has_permission?).with(:partners).returns(true).at_least_once

    stubs_at_least_one_service?(true)

    # user has permission to partners
    # user has at least one accessible services
    assert_category_present preferences_form.categories, :application

    stubs_at_least_one_service?(false)

    # user has permission to partners
    # user doesn't have at least one accessible services
    refute_category_present preferences_form.categories, :application

    stubs_at_least_one_service?(true)

    # user has permission to partners
    # user has at least one accessible services
    assert_category_present preferences_form.categories, :application

    @user.expects(:has_permission?).with(:partners).returns(false).at_least_once

    # user doesn't have permission to partners
    # user has at least one accessible services
    refute_category_present preferences_form.categories, :application
  end

  def test_categories_alert
    @user.expects(:has_permission?).returns(false).at_least_once
    @user.expects(:has_permission?).with(:monitoring).returns(true).at_least_once

    stubs_at_least_one_service?(true)

    # user has at least one accessible services
    # user has permission to monitoring
    assert_category_present preferences_form.categories, :alert

    stubs_at_least_one_service?(false)

    # user doesn't have at least one accessible services
    # user has permission to monitoring
    refute_category_present preferences_form.categories, :alert

    @user.expects(:has_permission?).with(:monitoring).returns(false).at_least_once

    stubs_at_least_one_service?(true)

    # user has at least one accessible services
    # user does not permission to monitoring
    refute_category_present preferences_form.categories, :alert
  end

  def test_categories_service
    @user.expects(:has_permission?).returns(false).at_least_once
    @user.expects(:has_permission?).with(:partners).returns(true).at_least_once

    stubs_at_least_one_service?(false)
    @provider.settings.expects(:service_plans_ui_visible?).returns(false).at_least_once

    # user doesn't have at least one accessible services
    # provider doesn't have service plans ui visible
    refute_category_present preferences_form.categories, :service

    stubs_at_least_one_service?(true)

    # user has at least one accessible services
    # provider doesn't have service plans ui visible
    assert_category_present preferences_form.categories, :service

    # only :service related notifications
    service_notifications = category_notifications(preferences_form.categories, :service)
    assert service_notifications.present?

    @provider.settings.expects(:service_plans_ui_visible?).returns(true).at_least_once

    # user has at least one accessible services
    # provider has service plans ui visible
    assert_category_present preferences_form.categories, :service

    # service related notifications + service plan related notification
    all_service_notifications = category_notifications(preferences_form.categories, :service)
    assert all_service_notifications.present?

    assert all_service_notifications.count > service_notifications.count

    # user doesn't have permission to partners
    @user.expects(:has_permission?).with(:partners).returns(false).at_least_once

    refute_category_present preferences_form.categories, :service
  end

  def test_categories_report
    @user.expects(:has_permission?).returns(false).at_least_once
    @user.expects(:has_permission?).with(:partners).returns(true).at_least_once
    @user.stubs(admin?: true)

    Rails.application.config.three_scale.stubs(daily_weekly_reports_pref: true)
    assert_category_present preferences_form.categories, :report

    Rails.application.config.three_scale.stubs(daily_weekly_reports_pref: false)
    refute_category_present preferences_form.categories, :report
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

  def stubs_at_least_one_service?(result)
    NotificationPreferencesForm.any_instance
      .stubs(:at_least_one_service?).returns(result)
  end

  def preferences_form
    NotificationPreferencesForm.new(@user, @user.notification_preferences)
  end

  def refute_category_present(categories, category_key)
    category = find_category_by_key(categories, category_key)

    refute category.present?
    refute category.try!(:notifications).present?
  end

  def assert_category_present(categories, category_key)
    category = find_category_by_key(categories, category_key)

    assert category.present?
    assert category.notifications.present?
  end

  def find_category_by_key(categories, key)
    categories.find { |c| c.title_key == key }
  end

  def category_notifications(categories, key)
    find_category_by_key(categories, key).notifications
  end
end
