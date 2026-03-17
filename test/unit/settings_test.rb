require 'test_helper'

class SettingsTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    @settings = @provider.settings
  end

  attr_reader :settings

  def test_hide_basic_switches
    Rails.configuration.three_scale.stubs(:hide_basic_switches).returns(true)
    assert Settings.hide_basic_switches?

    Rails.configuration.three_scale.stubs(:hide_basic_switches).returns(nil)
    assert_not Settings.hide_basic_switches?
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
    assert_not switch.hideable?

    switch.expects(:globally_denied?).returns(false)
    assert switch.hideable?

    Settings.stubs(:basic_hidden_switches).returns([name])
    switch.expects(:globally_denied?).returns(true)
    assert_not switch.hideable?

    switch.expects(:globally_denied?).returns(false)
    assert_not switch.hideable?
  end

  def test_approval_required
    @settings.expects(:not_custom_account_plans).returns([]).at_least_once

    assert_not @settings.approval_required_editable?
    assert_not @settings.approval_required_disabled?

    account_plan_1 = FactoryBot.build_stubbed(:simple_account_plan)
    @settings.expects(:not_custom_account_plans).returns([account_plan_1]).at_least_once

    assert @settings.approval_required_editable?
    assert_not @settings.approval_required_disabled?

    account_plan_2 = FactoryBot.build_stubbed(:simple_account_plan)
    @settings.expects(:not_custom_account_plans).returns([account_plan_1, account_plan_2]).at_least_once
    @settings.expects(:account_plans_ui_visible?).returns(true).at_least_once

    assert_not @settings.approval_required_editable?
    assert @settings.approval_required_disabled?
  end

  def test_update
    @settings.expects(:approval_required_editable?).returns(false).once
    @provider.account_plans.default.expects(:update_attribute).never

    @settings.update({ account_approval_required: true })

    @settings.expects(:approval_required_editable?).returns(true).once
    @provider.account_plans.default.expects(:update_attribute).once

    @settings.update({ account_approval_required: true })
  end

  test "account_approval_required delegated to default account plan" do
    plan = @provider.account_plans.default
    plan.update(approval_required: false)

    @settings.update(account_approval_required: true)
    assert plan.reload.approval_required

    @settings.update(account_approval_required: false)
    assert_not plan.reload.approval_required
  end

  test "accessing account_approval_required with hidden plan" do
    plan = @provider.account_plans.first
    @provider.update_attribute(:default_account_plan_id, nil)
    plan.hide!

    plan.update_attribute(:approval_required, true)
    @provider.reload
    assert @provider.settings.account_approval_required

    @provider.settings.update(account_approval_required: false)
    assert_not @provider.account_plans.first.approval_required
  end

  test "account_approval_required ignores empty values" do
    settings.update(account_approval_required: true)
    assert settings.account_approval_required

    settings.update(account_approval_required: "")
    assert settings.account_approval_required
  end

  test "not including account_approval_required doesn't disable it" do
    settings.update(account_approval_required: true)
    settings.update({})
    assert settings.account_approval_required
  end

  def test_service_plans_visible_ui_switch
   assert @settings.respond_to?(:service_plans_switch)
   assert @settings.respond_to?(:service_plans_ui_visible)
   @settings.service_plans_ui_visible = true
   assert @settings.visible_ui?(:service_plans)
   @settings.service_plans_ui_visible = false
   assert_not@settings.visible_ui?(:service_plans)
  end

  def test_require_cc_on_signup_visible_ui_switch_on_rolling_updates
    Logic::RollingUpdates.stubs(:enabled? => true)

    assert @settings.respond_to?(:require_cc_on_signup_switch)
    assert_not@settings.respond_to?(:require_cc_on_signup_ui_visible)

    Account.any_instance.stubs(:provider_can_use?).with(:require_cc_on_signup).returns(false)
    assert_not@settings.visible_ui?(:require_cc_on_signup)

    Account.any_instance.stubs(:provider_can_use?).with(:require_cc_on_signup).returns(true)
    assert @settings.visible_ui?(:require_cc_on_signup)
  end

  test 'enabling multi services sets limit to 3 services' do
    constraints = @provider.create_provider_constraints

    assert_not constraints.max_services
    @settings.allow_multiple_services!

    constraints.reload

    assert_equal 3, constraints.max_services
  end

  test 'finance globally denied on on-premises master' do
    account = Account.new
    settings = Settings.new
    settings.account = account

    ThreeScale.config.stubs(onpremises: false)
    assert_not settings.finance.globally_denied?

    ThreeScale.config.stubs(onpremises: true)
    assert_not settings.finance.globally_denied?

    ThreeScale.config.stubs(onpremises: false)
    account.master = true
    assert_not settings.finance.globally_denied?

    ThreeScale.config.stubs(onpremises: true)
    assert settings.finance.globally_denied?
    assert settings.finance.denied?
    assert_not settings.finance.visible?
    assert_not settings.finance.allowed?
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

  test 'boolean setting assignment semantics' do
    settings.update(public_search: true)
    assert settings.reload.public_search

    settings.update(public_search: false)
    assert_not settings.reload.public_search, "explicit false should change the setting"

    settings.update(public_search: true)
    settings.update(public_search: nil)
    assert_nil settings.reload.public_search, "nil clears the setting back to default"
  end

  test "validate change plan permission values" do
    assert_equal 'request', settings.change_account_plan_permission
    assert_equal 'request', settings.change_service_plan_permission

    assert_not settings.update(change_account_plan_permission: 'invalid', change_service_plan_permission: 'invalid')
    assert_equal 'request', settings.reload.change_account_plan_permission
    assert_equal 'request', settings.reload.change_service_plan_permission
  end

  test "assign value then nil on a new setting removes the record" do
    assert_nil @provider.account_settings.detect { |r| r.type == 'BgColour' }

    settings.bg_colour = '#fff'
    assert @provider.account_settings.detect { |r| r.type == 'BgColour' }, "record should exist in memory"

    settings.bg_colour = nil
    assert_nil settings.bg_colour, "getter should return default after nil assignment"

    settings.save!
    assert_nil @provider.account_settings.reload.detect { |r| r.type == 'BgColour' },
      "no record should be persisted"
  end

  test "assign nil then a new value on a persisted setting resurrects the record" do
    settings.update!(bg_colour: '#fff')
    assert_equal '#fff', settings.reload.bg_colour

    settings.bg_colour = nil
    assert_nil settings.bg_colour, "getter should return default after nil assignment"

    settings.bg_colour = '#000'
    assert_equal '#000', settings.bg_colour, "getter should return the new value"

    settings.save!
    assert_equal '#000', settings.reload.bg_colour, "new value should be persisted"
    assert_equal 1, @provider.account_settings.select { |r| r.type == 'BgColour' }.size,
      "should have exactly one record, not a duplicate"
  end

  class FinanceDisabledSwitchTest < ActiveSupport::TestCase
    def setup
      @provider = FactoryBot.build_stubbed(:simple_provider)
    end

    test 'finance is denied when globally denied' do
      @provider.stubs(master_on_premises?: true)
      finance = @provider.settings.finance

      assert finance.globally_denied?
      assert finance.denied?
      assert_not finance.allowed?
      assert_not finance.visible?
      assert_not finance.hidden?
      assert_not finance.allow
    end

  end
end
