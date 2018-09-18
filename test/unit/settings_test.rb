require 'test_helper'

class SettingsTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryGirl.create(:provider_account)
    @settings = @provider.settings
  end

  def test_hide_basic_switches
    Rails.configuration.three_scale.stubs(:hide_basic_switches).returns(true)
    assert Settings.hide_basic_switches?

    Rails.configuration.three_scale.stubs(:hide_basic_switches).returns(nil)
    refute Settings.hide_basic_switches?
  end

  def test_basic_switches
    Settings.stubs(:hide_basic_switches?).returns(true)
    assert_not_empty Settings.basic_enabled_switches
    assert_not_empty Settings.basic_disabled_switches
    assert_not_empty Settings.basic_hidden_switches

    Settings.stubs(:hide_basic_switches?).returns(nil)
    assert_empty Settings.basic_enabled_switches
    assert_empty Settings.basic_disabled_switches
    assert_empty Settings.basic_hidden_switches
  end

  def test_hideable
    name, switch = @settings.switches.first

    Settings.stubs(:basic_hidden_switches).returns([])
    switch.expects(:globally_denied?).returns(true)
    refute switch.hideable?

    switch.expects(:globally_denied?).returns(false)
    assert switch.hideable?

    Settings.stubs(:basic_hidden_switches).returns([name])
    switch.expects(:globally_denied?).returns(true)
    refute switch.hideable?

    switch.expects(:globally_denied?).returns(false)
    refute switch.hideable?
  end

  def test_approval_required
    @settings.expects(:not_custom_account_plans).returns([]).at_least_once

    refute @settings.approval_required_editable?
    refute @settings.approval_required_disabled?

    account_plan_1 = FactoryGirl.build_stubbed(:simple_account_plan)
    @settings.expects(:not_custom_account_plans).returns([account_plan_1]).at_least_once

    assert @settings.approval_required_editable?
    refute @settings.approval_required_disabled?

    account_plan_2 = FactoryGirl.build_stubbed(:simple_account_plan)
    @settings.expects(:not_custom_account_plans).returns([account_plan_1, account_plan_2]).at_least_once
    @settings.expects(:account_plans_ui_visible?).returns(true).at_least_once

    refute @settings.approval_required_editable?
    assert @settings.approval_required_disabled?
  end

  def test_update_attributes
    @settings.expects(:approval_required_editable?).returns(false).once
    @provider.account_plans.default.expects(:update_attribute).never

    @settings.update_attributes({ account_approval_required: true })

    @settings.expects(:approval_required_editable?).returns(true).once
    @provider.account_plans.default.expects(:update_attribute).once

    @settings.update_attributes({ account_approval_required: true })
  end

  test "account_approval_required delegated to default account plan" do
    plan = @provider.account_plans.default
    plan.update_attributes(approval_required: false)

    @settings.update_attributes(account_approval_required: true)
    assert plan.reload.approval_required

    @settings.update_attributes(welcome_text: :bar)
    assert_equal false, plan.reload.approval_required

    @settings.update_attributes(account_approval_required: false)
    refute plan.reload.approval_required
  end


  # regression for https://3scale.airbrake.io/projects/14982/groups/70314326/notices/1098522869916472518
  test "accessing account_approval_required with hidden plan" do
    plan = @provider.account_plans.first
    @provider.update_attribute(:default_account_plan_id, nil)
    plan.hide!

    plan.update_attribute(:approval_required, true)
    assert @settings.reload.account_approval_required

    @settings.update_attributes(account_approval_required: false)
    refute @provider.account_plans.first.approval_required
  end

  def test_end_users_invisible_ui_switch
    assert @settings.has_attribute?(:end_users_switch)
    assert @settings.visible_ui?(:end_users)
    refute @settings.has_attribute?(:end_users_ui_visible)
  end

  def test_service_plans_visible_ui_switch
   assert @settings.has_attribute?(:service_plans_switch)
   assert @settings.has_attribute?(:service_plans_ui_visible)
   @settings.service_plans_ui_visible = true
   assert @settings.visible_ui?(:service_plans)
   @settings.service_plans_ui_visible = false
   refute @settings.visible_ui?(:service_plans)
  end

  def test_require_cc_on_signup_visible_ui_switch_on_rolling_updates
    Logic::RollingUpdates.stubs(:enabled? => true)

    assert @settings.has_attribute?(:require_cc_on_signup_switch)
    refute @settings.has_attribute?(:require_cc_on_signup_ui_visible)

    Account.any_instance.stubs(:provider_can_use?).with(:require_cc_on_signup).returns(false)
    refute @settings.visible_ui?(:require_cc_on_signup)

    Account.any_instance.stubs(:provider_can_use?).with(:require_cc_on_signup).returns(true)
    assert @settings.visible_ui?(:require_cc_on_signup)
  end

  test 'enabling multi services sets limit to 3 services' do
    constraints = @provider.create_provider_constraints

    refute constraints.max_services
    @settings.allow_multiple_services!

    constraints.reload

    assert_equal 3, constraints.max_services
  end

  test 'finance is a subclass of Switch' do
    account = Account.new
    settings = Settings.new
    settings.account = account

    ThreeScale.config.stubs(onpremises: false)
    refute settings.finance.globally_denied?
    assert_instance_of Settings::Switch, settings.finance

    ThreeScale.config.stubs(onpremises: true)
    assert_instance_of Settings::Switch, settings.finance

    ThreeScale.config.stubs(onpremises: false)
    account.master = true
    refute settings.finance.globally_denied?
    assert_instance_of Settings::Switch, settings.finance

    ThreeScale.config.stubs(onpremises: true)
    assert settings.finance.globally_denied?
    assert_instance_of Settings::SwitchDenied, settings.finance

  end

  test 'settings autosaved if account saved' do
    settings = @provider.settings
    settings.update! monthly_billing_enabled: false
    settings.monthly_billing_enabled = true
    @provider.org_name = 'hello world'
    @provider.save!
    settings.reload
    assert settings.monthly_billing_enabled
  end

  class FinanceDisabledSwitchTest < ActiveSupport::TestCase
    def setup
      @provider = FactoryGirl.build_stubbed(:simple_provider)
      @finance = Settings::SwitchDenied.new(@provider.settings, :finance)
    end

    test 'finance is denied' do
      refute @finance.allow
      refute @finance.allowed?

      refute @finance.show!
      refute @finance.visible?

      assert @finance.deny
      assert @finance.denied?

      refute @finance.hide!
      refute @finance.hidden?

      assert @finance.globally_denied?
    end

    test '::globally_denied_switches for finance' do
      @provider.stubs(master?: true)
      ThreeScale.config.stubs(onpremises: false)
      assert_equal [], @provider.settings.globally_denied_switches

      ThreeScale.config.stubs(onpremises: true)
      assert_equal [:finance], @provider.settings.globally_denied_switches

      @provider.unstub(:master?)
      ThreeScale.config.stubs(onpremises: false)
      assert_equal [], @provider.settings.globally_denied_switches

      ThreeScale.config.stubs(onpremises: true)
      assert_equal [], @provider.settings.globally_denied_switches
    end
  end
end
