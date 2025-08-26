require 'test_helper'

class NotificationCategoriesTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.build_stubbed(:simple_provider)
    @user     = FactoryBot.build_stubbed(:simple_user, account: @provider)
  end

  def test_categories_billing
    @provider.stubs(:is_billing_buyers?).returns(true)
    @user.expects(:has_permission?).with(:finance).returns(true).at_least_once
    stubs_at_least_one_service?(true)

    # user has permission to billing
    # provider is billing his buyers
    assert target.enabled? :billing

    ThreeScale.config.stubs(onpremises: true)
    @provider.stubs(master?: true)
    assert_not target.enabled? :billing
    ThreeScale.config.stubs(onpremises: false)
    @provider.unstub(:master?)

    @user.expects(:has_permission?).with(:finance).returns(false).at_least_once

    # user doesn't have permission to billing
    # provider is billing his buyers
    assert_not target.enabled? :billing

    @user.expects(:has_permission?).with(:finance).returns(true).at_least_once

    # user has permission to billing
    # provider is billing his buyers
    assert target.enabled? :billing

    @provider.expects(:is_billing_buyers?).returns(false).at_least_once

    # user has permission to billing
    # provider is not billing his buyers
    assert_not target.enabled? :billing
  end

  def test_categories_account
    @user.expects(:has_permission?).with(:partners).returns(true).at_least_once

    # user has permission to partners
    assert target.enabled? :account

    @user.expects(:has_permission?).with(:partners).returns(false).at_least_once

    # user doesn't have permission to partners
    assert_not target.enabled? :account
  end

  def test_categories_application
    @user.expects(:has_permission?).with(:partners).returns(true).at_least_once

    stubs_at_least_one_service?(true)

    # user has permission to partners
    # user has at least one accessible services
    assert target.enabled? :application

    stubs_at_least_one_service?(false)

    # user has permission to partners
    # user doesn't have at least one accessible services
    assert_not target.enabled? :application

    stubs_at_least_one_service?(true)

    # user has permission to partners
    # user has at least one accessible services
    assert target.enabled? :application

    @user.expects(:has_permission?).with(:partners).returns(false).at_least_once

    # user doesn't have permission to partners
    # user has at least one accessible services
    assert_not target.enabled? :application
  end

  def test_categories_alert
    @user.expects(:has_permission?).with(:monitoring).returns(true).at_least_once

    stubs_at_least_one_service?(true)

    # user has at least one accessible services
    # user has permission to monitoring
    assert target.enabled? :alert

    stubs_at_least_one_service?(false)

    # user doesn't have at least one accessible services
    # user has permission to monitoring
    assert_not target.enabled? :alert

    @user.expects(:has_permission?).with(:monitoring).returns(false).at_least_once

    stubs_at_least_one_service?(true)

    # user has at least one accessible services
    # user does not permission to monitoring
    assert_not target.enabled? :alert
  end

  def test_categories_service
    @user.expects(:has_permission?).with(:partners).returns(true).at_least_once

    stubs_at_least_one_service?(false)

    # user doesn't have at least one accessible services
    # provider doesn't have service plans ui visible
    assert_not target.enabled? :service

    stubs_at_least_one_service?(true)

    # user has at least one accessible services
    # provider doesn't have service plans ui visible
    assert target.enabled? :service

    # user doesn't have permission to partners
    @user.expects(:has_permission?).with(:partners).returns(false).at_least_once

    assert_not target.enabled? :service
  end

  def test_categories_service_plan
    @user.stubs(:has_permission?).with(:partners).returns(true)
    stubs_at_least_one_service?(true)
    @provider.settings.stubs(:service_plans_ui_visible?).returns(true)
    assert target.enabled? :service_plan

    @user.stubs(:has_permission?).with(:partners).returns(true)
    stubs_at_least_one_service?(true)
    @provider.settings.stubs(:service_plans_ui_visible?).returns(false)
    assert_not target.enabled? :service_plan

    @user.stubs(:has_permission?).with(:partners).returns(true)
    stubs_at_least_one_service?(false)
    @provider.settings.stubs(:service_plans_ui_visible?).returns(true)
    assert_not target.enabled? :service_plan

    @user.stubs(:has_permission?).with(:partners).returns(false)
    stubs_at_least_one_service?(true)
    @provider.settings.stubs(:service_plans_ui_visible?).returns(true)
    assert_not target.enabled? :service_plan
  end

  def test_categories_report
    @user.expects(:has_permission?).with(:partners).returns(true).at_least_once
    @user.stubs(admin?: true)

    Rails.application.config.three_scale.stubs(daily_weekly_reports_pref: true)
    assert target.enabled? :report

    Rails.application.config.three_scale.stubs(daily_weekly_reports_pref: false)
    assert_not target.enabled? :report
  end

  private

  def stubs_at_least_one_service?(result)
    NotificationCategories.any_instance
                          .stubs(:at_least_one_service?).returns(result)
  end

  def target
    @target ||= NotificationCategories.new(@user)
  end
end
