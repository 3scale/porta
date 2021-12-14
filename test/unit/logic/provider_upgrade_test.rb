require 'test_helper'

class Logic::ProviderUpgradeTest < ActiveSupport::TestCase

  def setup
    service = master_account.first_service!
    @provider = FactoryBot.create(:provider_account)
    @power1M = FactoryBot.create(:published_plan, :system_name => 'power1M', :issuer => service)
    @power1M.plan_rule.stubs(:switches).returns(%i[finance multiple_applications branding require_cc_on_signup
      account_plans multiple_users groups]
    )
    @power1M.plan_rule.stubs(:limits).returns(PlanRule::Limit.new(max_services: 1, max_users: 1))
    @power1M.plan_rule.stubs(:rank).returns(10)
    @pro = FactoryBot.create(:published_plan, :system_name => 'pro3M', :issuer => service)
    @pro.plan_rule.stubs(:switches).returns(%i[finance multiple_applications branding require_cc_on_signup account_plans
      multiple_users groups multiple_services service_plans]
    )
    @pro.plan_rule.stubs(:limits).returns(PlanRule::Limit.new(max_services: 3, max_users: 5))
    @pro.plan_rule.stubs(:rank).returns(19)
    @base = FactoryBot.create(:published_plan, :system_name => 'base', :issuer => service)
    @base.plan_rule.stubs(:limits).returns(PlanRule::Limit.new(max_services: 1, max_users: 1))
  end

  def test_hideable_switches
    Settings::Switch.any_instance.stubs(:hideable?).returns(true)
    assert_not_empty @provider.hideable_switches

    Settings::Switch.any_instance.stubs(:hideable?).returns(false)
    assert_empty @provider.hideable_switches
  end

  test 'first_plan_with_switch' do
    assert_kind_of ApplicationPlan, @provider.first_plan_with_switch('finance')
    assert_nil @provider.first_plan_with_switch('bananas')
  end

  test 'upgrade from base to power1M' do
    @provider.stubs(:credit_card_stored?).returns(true)
    @provider.upgrade_to_provider_plan!(@power1M)

    assert_equal 'power1M', @provider.reload.bought_cinstance.plan.system_name
    assert @provider.settings.finance.visible?, 'Finance should be visible on Power1M'
  end

  test 'upgrade through force_upgrade_to_provider_plan! bypasses can_upgrade?' do
    @provider.stubs(:credit_card_stored?).returns(true)
    PlanRulesCollection.stubs(can_upgrade?: false) do
      @provider.force_upgrade_to_provider_plan!(@power1M)
    end
  end

  test 'raises if not credit_card_stored?' do
    @provider.stubs(:credit_card_stored?).returns(false)
    PlanRulesCollection.stubs(can_upgrade?: true) do
      assert_raises(RuntimeError) { @provider.upgrade_to_provider_plan!(@power1M) }
    end
  end

  test 'raises unless can_upgrade?' do
    @provider.stubs(:credit_card_stored?).returns(true)
    PlanRulesCollection.stubs(can_upgrade?: false) do
      assert_raises(RuntimeError) { @provider.upgrade_to_provider_plan!(@power1M) }
    end
  end

  test 'can call force_upgrade_to_provider_plan! with a master plan system_name' do
    @provider.force_upgrade_to_provider_plan! @power1M
    assert_equal 'power1M', @provider.reload.bought_cinstance.plan.system_name
  end

  test 'force_to_change_plan!' do
    issuer = master_account.first_service!
    plan = FactoryBot.create(:application_plan, issuer: issuer, name: "plus", system_name: "plus")
    @provider.stubs(:provider_can_use?).with(:require_cc_on_signup).returns(false)


    @provider.force_to_change_plan!(plan)
    switches_on = @provider.available_plans[plan.system_name]

    settings = @provider.settings
    switches_on.each do |switch|
      assert settings.send(switch).allowed?
    end

    switches_off = Switches::SWITCHES - switches_on
    switches_off.each do |switch|
      assert settings.send(switch).denied?
    end


    switches_on.each do |switch|
      assert settings.send(switch).visible?, "#{switch} switch is not visible" if Switches::THREESCALE_VISIBLE_SWITCHES.include?(switch)
    end

    plan = @base
    @provider.force_to_change_plan!(plan)
    switches_on = @provider.available_plans[plan.system_name]

    settings = @provider.settings
    switches_on.each do |switch|
      assert settings.send(switch).allowed?
    end

    switches_off = Switches::SWITCHES - switches_on
    switches_off.each do |switch|
      assert settings.send(switch).denied?, "#{switch} switch is not denied"
    end

    switches_on.each do |switch|
      assert settings.send(switch).visible?, "#{switch} switch is not visible" if Switches::THREESCALE_VISIBLE_SWITCHES.include?(switch)
    end
  end

  test 'force_to_change_plan! for require_cc_on_signup switch' do
    @provider.stubs(:provider_can_use?).returns(true)
    assert @provider.settings.require_cc_on_signup.denied?

    @provider.stubs(:provider_can_use?).with(:require_cc_on_signup).returns(false)
    @provider.force_to_change_plan! @power1M
    assert @provider.settings.require_cc_on_signup.visible?

    other_provider = FactoryBot.create :provider_account
    assert other_provider.settings.require_cc_on_signup.denied?
    other_provider.stubs(:provider_can_use?).returns(true)

    other_provider.force_to_change_plan! @power1M
    assert other_provider.settings.require_cc_on_signup.hidden?
  end

  test 'provider constraint is modified when upgrading' do
    assert constraints = @provider.build_provider_constraints(max_users: 1, max_services: 1)

    refute constraints.can_create_user?
    refute constraints.can_create_service?

    @provider.stubs(:credit_card_stored?).returns(true)
    @provider.upgrade_to_provider_plan!(@pro)

    assert constraints.can_create_user?
    assert constraints.can_create_service?
  end

  test 'provider constraint is modified when downgrading' do
    constraints = @provider.build_provider_constraints(max_users: 5, max_services: 5)

    @provider.stubs(:credit_card_stored?).returns(true)
    @provider.force_upgrade_to_provider_plan!(@base)

    refute constraints.can_create_user?
    refute constraints.can_create_service?
  end

  test 'first update switch, then limits' do
    constraints = @provider.create_provider_constraints!

    assert_difference(Audited.audit_class.method(:count), +2) do
      ProviderConstraints.with_synchronous_auditing do
        assert constraints.auditing_enabled?, 'auditing should be enabled'
        @provider.force_upgrade_to_provider_plan!(@pro)
      end
    end

    switch_audit, upgrade_audit = Audited.audit_class.order(:id).last(2)

    assert_equal 'Upgrading max_services because of switch is enabled.', switch_audit.comment
    assert_equal 'Upgrading limits to match plan pro3M', upgrade_audit.comment

    assert_equal 3, constraints.max_services
  end

  test 'update_provider_constraints_to' do
    assert @provider.update_provider_constraints_to({max_users: 1}, 'updating users')
    assert @provider.update_provider_constraints_to({max_services: 1}, 'updating services')

    assert constraints = @provider.provider_constraints
    assert_equal 1, constraints.max_users
    assert_equal 1, constraints.max_services
  end

  test 'checking if available_plans on provider are a hash' do
    partner = FactoryBot.create(:partner)
    provider = FactoryBot.create(:simple_provider, partner: partner)

    assert provider.available_plans.keys.empty?
  end

  test 'available_switches for partner' do
    partner = FactoryBot.create(:partner)
    provider =  FactoryBot.create(:simple_provider, partner: partner)

    partner.system_name = 'redhat'
    assert_includes provider.available_switches.map(&:name), :multiple_users

    partner.system_name = ''
    assert_includes provider.available_switches.map(&:name), :multiple_users
  end

  test 'settings on after contracting a plan depending on having a partner or not' do
    @provider.stubs(:credit_card_stored?).returns(true)
    @provider.stubs(:can_upgrade_to?).returns(true)
    plan_switches = @power1M.switches

    @provider.stubs(:partner).returns(Partner.new)
    @provider.upgrade_to_provider_plan!(@power1M)
    refute plan_switches.any? { |switch| @provider.settings.send(switch).allowed? }

    @provider.stubs(:partner).returns(nil)
    @provider.upgrade_to_provider_plan!(@power1M)
    assert plan_switches.all? { |switch| @provider.settings.send(switch).allowed? }
  end
end
