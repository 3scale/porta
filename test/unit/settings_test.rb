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

  test "account_approval_required getter delegates to default account plan" do
    plan = @provider.account_plans.default
    plan.update!(approval_required: true)
    assert @settings.account_approval_required

    plan.update!(approval_required: false)
    assert_not @settings.account_approval_required
  end

  test "account_approval_required passed to settings.update is silently ignored" do
    # The facade has no write path for account_approval_required —
    # controllers must handle it explicitly before calling settings.update.
    plan = @provider.account_plans.default
    plan.update!(approval_required: false)

    assert_nothing_raised { @settings.update(account_approval_required: true, signups_enabled: false) }
    assert_not plan.reload.approval_required, "facade must not write account_approval_required"
    assert_not @settings.signups_enabled, "other params still applied"
  end

  test "accessing account_approval_required with hidden plan" do
    plan = @provider.account_plans.first
    @provider.update_attribute(:default_account_plan_id, nil)
    plan.hide!

    plan.update_attribute(:approval_required, true)
    @provider.reload
    assert @provider.settings.account_approval_required
  end

  def test_service_plans_visible_ui_switch
   assert @settings.respond_to?(:service_plans)
   assert @settings.respond_to?(:service_plans_ui_visible)
   @settings.service_plans_ui_visible = true
   assert @settings.visible_ui?(:service_plans)
   @settings.service_plans_ui_visible = false
   assert_not @settings.visible_ui?(:service_plans)
  end

  def test_require_cc_on_signup_visible_ui_switch_on_rolling_updates
    Logic::RollingUpdates.stubs(:enabled? => true)

    assert @settings.respond_to?(:require_cc_on_signup)
    assert_not @settings.respond_to?(:require_cc_on_signup_ui_visible)

    Account.any_instance.stubs(:provider_can_use?).with(:require_cc_on_signup).returns(false)
    assert_not @settings.visible_ui?(:require_cc_on_signup)

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
    settings = Settings.new(account)

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
    assert_not settings.finance.hidden?
    assert_not settings.finance.allow
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
    # Direct Ruby booleans
    settings.public_search = true
    assert_equal true, settings.public_search
    assert_equal true, settings.public_search?
    settings.save!
    assert_equal true, settings.reload.public_search
    assert_equal true, @provider.account_settings.find_by(type: AccountSetting::PublicSearch.sti_name).value

    settings.public_search = false
    assert_equal false, settings.public_search
    assert_equal false, settings.public_search?
    settings.save!
    assert_equal false, settings.reload.public_search
    assert_equal false, @provider.account_settings.find_by(type: AccountSetting::PublicSearch.sti_name).value

    # Integer inputs (e.g., from forms/params)
    settings.update(public_search: 1)
    assert_equal true, settings.reload.public_search

    settings.update(public_search: 0)
    assert_equal false, settings.reload.public_search

    # String inputs (e.g., "1"/"0", "true"/"false", "t"/"f")
    settings.update(public_search: '1')
    assert_equal true, settings.reload.public_search

    settings.update(public_search: '0')
    assert_equal false, settings.reload.public_search

    settings.update(public_search: 'true')
    assert_equal true, settings.reload.public_search

    settings.update(public_search: 'false')
    assert_equal false, settings.reload.public_search

    settings.update(public_search: 't')
    assert_equal true, settings.reload.public_search

    settings.update(public_search: 'f')
    assert_equal false, settings.reload.public_search

    # Clearing via nil returns default value (false)
    settings.update(public_search: true)
    settings.update(public_search: nil)
    assert_equal false, settings.reload.public_search, "nil clears the setting back to default (false)"
    assert_nil @provider.account_settings.find_by(type: AccountSetting::PublicSearch.sti_name)

    # Boolean setting with true default (documentation_public defaults to true)
    @provider.account_settings.where(type: AccountSetting::DocumentationPublic.sti_name).delete_all
    settings.reload
    assert_equal true, settings.documentation_public
    settings.update(documentation_public: false)
    assert_equal false, settings.reload.documentation_public
    assert_equal false, @provider.account_settings.find_by(type: AccountSetting::DocumentationPublic.sti_name).value

    settings.update(documentation_public: nil)
    assert_equal true, settings.reload.documentation_public, "nil clears the setting back to default (true)"
    assert_nil @provider.account_settings.find_by(type: AccountSetting::DocumentationPublic.sti_name)
  end

  test "validate change plan permission values" do
    assert_equal 'request', settings.change_account_plan_permission
    assert_equal 'request', settings.change_service_plan_permission

    assert_not settings.update(change_account_plan_permission: 'invalid', change_service_plan_permission: 'invalid')
    assert_equal 'request', settings.reload.change_account_plan_permission
    assert_equal 'request', settings.reload.change_service_plan_permission
  end

  test "save! raises RecordInvalid with the offending record on validation failure" do
    settings.change_account_plan_permission = 'invalid'
    error = assert_raises(ActiveRecord::RecordInvalid) { settings.save! }
    assert_match(/is not included in the list/, error.message)
  end

  test "errors aggregates validation errors from AccountSetting records" do
    settings.change_account_plan_permission = 'invalid'
    settings.change_service_plan_permission = 'invalid'
    settings.save

    errors = settings.errors
    assert errors[:change_account_plan_permission].any?, "should have error on change_account_plan_permission"
    assert errors[:change_service_plan_permission].any?, "should have error on change_service_plan_permission"
    assert_match(/is not included in the list/, errors[:change_account_plan_permission].first)
  end

  test "authentication_strategy returns a StringInquirer" do
    settings.update!(authentication_strategy: 'oauth2')
    strategy = settings.authentication_strategy
    assert_kind_of ActiveSupport::StringInquirer, strategy
    assert strategy.oauth2?
    assert_not strategy.internal?

    settings.update!(authentication_strategy: 'internal')
    strategy = settings.reload.authentication_strategy
    assert strategy.internal?
    assert_not strategy.oauth2?
  end

  test "updated_at returns the latest AccountSetting timestamp" do
    settings.update!(bg_colour: '#aaa')
    assert_not_nil settings.updated_at
    assert_kind_of ActiveSupport::TimeWithZone, settings.updated_at

    ts = @provider.account_settings.maximum(:updated_at)
    assert_equal ts, settings.updated_at
  end

  test "assign value then nil on a new setting removes the record" do
    assert_nil @provider.account_settings.detect { |r| r.type == AccountSetting::BgColour.sti_name }

    settings.bg_colour = '#fff'
    assert @provider.account_settings.detect { |r| r.type == AccountSetting::BgColour.sti_name }, "record should exist in memory"

    settings.bg_colour = nil
    assert_nil settings.bg_colour, "getter should return default after nil assignment"

    settings.save!
    assert_nil @provider.account_settings.reload.detect { |r| r.type == AccountSetting::BgColour.sti_name },
      "no record should be persisted"
  end

  test "assign value, nil, then new value on a non-existing setting persists only the final value" do
    assert_nil @provider.account_settings.detect { |r| r.type == AccountSetting::BgColour.sti_name }

    settings.bg_colour = '#111111'
    assert_equal '#111111', settings.bg_colour
    assert @provider.account_settings.detect { |r| r.type == AccountSetting::BgColour.sti_name }

    settings.bg_colour = nil
    assert_nil settings.bg_colour
    assert_nil @provider.account_settings.detect { |r| r.type == AccountSetting::BgColour.sti_name }

    settings.bg_colour = '#222222'
    assert_equal '#222222', settings.bg_colour

    settings.save!
    assert_equal '#222222', settings.reload.bg_colour
    assert_equal '#222222', @provider.account_settings.find_by(type: AccountSetting::BgColour.sti_name).value
    assert_equal 1, @provider.account_settings.select { |r| r.type == AccountSetting::BgColour.sti_name }.size
  end

  test "assign value, nil, then new value on a pre-existing setting updates the record without duplicates" do
    settings.update!(bg_colour: '#111111')
    assert_equal '#111111', settings.reload.bg_colour

    settings.bg_colour = '#222222'
    assert_equal '#222222', settings.bg_colour

    settings.bg_colour = nil
    assert_nil settings.bg_colour, "getter should return default after nil assignment"

    settings.bg_colour = '#333333'
    assert_equal '#333333', settings.bg_colour, "getter should return the new value"

    settings.save!
    assert_equal '#333333', settings.reload.bg_colour, "new value should be persisted"
    assert_equal '#333333', @provider.account_settings.find_by(type: AccountSetting::BgColour.sti_name).value
    assert_equal 1, @provider.account_settings.select { |r| r.type == AccountSetting::BgColour.sti_name }.size,
      "should have exactly one record, not a duplicate"
  end

  test "resurrecting a marked-for-destruction record resets value to default" do
    settings.update!(monthly_billing_enabled: false)
    assert_equal false, settings.reload.monthly_billing_enabled

    settings.monthly_billing_enabled = nil
    record = settings.send(:find_or_build_setting, :monthly_billing_enabled)

    assert_not record.marked_for_destruction?, "record should be unmarked"
    assert_equal true, record.value, "value should be reset to default (true), not stale (false)"
  end

  test "update_attribute persists setting immediately" do
    settings.update_attribute(:bg_colour, '#654321')
    assert_equal '#654321', settings.reload.bg_colour
    assert_equal '#654321', @provider.account_settings.find_by(type: AccountSetting::BgColour.sti_name).value

    settings.update_attribute(:bg_colour, '#123456')
    assert_equal '#123456', settings.reload.bg_colour
    assert_equal '#123456', @provider.account_settings.find_by(type: AccountSetting::BgColour.sti_name).value
  end

  test "update_attribute with nil immediately destroys the persisted record" do
    settings.update_attribute(:bg_colour, '#654321')
    assert_equal '#654321', @provider.account_settings.find_by(type: AccountSetting::BgColour.sti_name).value

    settings.update_attribute(:bg_colour, nil)
    assert_nil settings.bg_colour
    assert_nil settings.reload.bg_colour
    assert_nil @provider.account_settings.find_by(type: AccountSetting::BgColour.sti_name)
  end

  test "update_attribute with nil on non-existent setting is a safe no-op" do
    assert_nil @provider.account_settings.find_by(type: AccountSetting::BgColour.sti_name)
    settings.update_attribute(:bg_colour, nil)
    assert_nil settings.bg_colour
    assert_nil @provider.account_settings.find_by(type: AccountSetting::BgColour.sti_name)
  end

  test "destroying an AccountSetting directly updates facade to default, and reassigning works cleanly" do
    settings.update_attribute(:bg_colour, '#123456')
    assert_equal '#123456', settings.bg_colour

    # Directly destroy the AccountSetting record outside the facade
    record = @provider.account_settings.detect { |r| r.type == AccountSetting::BgColour.sti_name }
    record.destroy

    # Facade should immediately return default without reload
    assert_nil settings.bg_colour

    # Reassigning should build a fresh record, persist, and update getter
    settings.bg_colour = '#abcdef'
    assert_equal '#abcdef', settings.bg_colour

    settings.save!
    assert_equal '#abcdef', settings.reload.bg_colour
    assert_equal '#abcdef', @provider.account_settings.find_by(type: AccountSetting::BgColour.sti_name).value
  end

  test 'exposes attribute types and error messages to form builders' do
    assert_equal :boolean, Settings.type_for_attribute(:forum_enabled).type
    assert_equal :string, Settings.type_for_attribute(:bg_colour).type
    assert_nil Settings.type_for_attribute(:finance).type
    assert_equal 'finance', Settings.type_for_attribute(:finance) { |name| name }

    settings.product = 'invalid'
    assert_not settings.save
    assert_includes settings.errors.full_messages.join, 'Product'
  end

  test 'toggle! flips a true-default boolean when no record is stored' do
    assert_not settings.value_set?(:monthly_charging_enabled)
    assert settings.monthly_charging_enabled

    assert_equal false, settings.toggle!(:monthly_charging_enabled)
    assert_equal false, settings.reload.monthly_charging_enabled
  end

  class PersistedTest < ActiveSupport::TestCase
    test 'false when account is nil' do
      assert_not Settings.new.persisted?
      assert_not Settings.new.save
      assert_raises(ActiveRecord::RecordNotSaved) { Settings.new.save! }
    end

    test 'setting a value without an account raises' do
      assert_raises(RuntimeError, /without an account/) { Settings.new.bg_colour = '#fff' }
    end

    test 'setting an unknown name raises KeyError' do
      provider = FactoryBot.create(:simple_provider)
      settings = provider.settings
      assert_raises(KeyError) { settings.send(:find_or_build_setting, :nonexistent_setting) }
    end

    test 'false when account is not persisted' do
      provider = FactoryBot.build(:simple_provider)
      assert_not provider.settings.persisted?
      assert_not provider.settings.save
      assert_raises(ActiveRecord::RecordNotSaved) { provider.settings.save! }
    end

    test 'true when account is persisted' do
      provider = FactoryBot.create(:simple_provider)
      settings = provider.settings
      assert settings.persisted?

      # Remains persisted even when settings have in-memory modifications
      settings.bg_colour = '#fff'
      assert settings.persisted?
    end
  end

  class SSOKeyTest < ActiveSupport::TestCase
    def setup
      @provider = FactoryBot.create(:provider_account)
      @settings = @provider.settings
    end

    test 'returns nil for non-provider accounts' do
      buyer = FactoryBot.create(:simple_buyer, provider_account: @provider)
      assert_nil buyer.settings.sso_key
    end

    test 'lazily generates and persists sso_key on first access' do
      assert_not @settings.value_set?(:sso_key)

      key = @settings.sso_key
      assert_not_nil key
      assert_kind_of String, key
      assert key.length > 10, "sso_key should be a non-trivial string"

      db_record = AccountSetting.find_by(account_id: @provider.id, type: AccountSetting::SSOKey.sti_name)
      assert_not_nil db_record, "sso_key record should be persisted in the database"
      assert_equal key, db_record.value
    end

    test 'returns the same key on subsequent reads' do
      assert_not @settings.value_set?(:sso_key)

      key1 = @settings.sso_key
      key2 = @settings.sso_key
      assert_equal key1, key2, "sso_key should be stable across reads"
    end

    test 'returns existing key without generating a new one' do
      AccountSetting.create!(account_id: @provider.id, type: AccountSetting::SSOKey.sti_name, value: 'pre_existing_key')
      @provider.account_settings.reload

      assert_equal 'pre_existing_key', @settings.sso_key
    end

    test 'tenant_id is set by DB trigger' do
      assert_not @settings.value_set?(:sso_key)

      @settings.sso_key
      db_tenant_id = ActiveRecord::Base.connection.select_value(
        "SELECT tenant_id FROM account_settings WHERE account_id = #{@provider.id} AND type = '#{AccountSetting::SSOKey.sti_name}'"
      )
      assert_equal @provider.tenant_id, db_tenant_id.to_i, "tenant_id should be set by DB trigger"
    end

    test 'uses a key created concurrently after account settings were loaded' do
      assert_not @settings.value_set?(:sso_key)
      sso_keys = AccountSetting.where(account_id: @provider.id, type: AccountSetting::SSOKey.sti_name)
      AccountSetting.create!(account_id: @provider.id, type: AccountSetting::SSOKey.sti_name, value: 'winner_key')

      assert_equal 'winner_key', @settings.sso_key
      assert_equal 1, sso_keys.count

      @settings.sso_key = 'new_key'
      @settings.save!

      assert_equal %w[new_key], sso_keys.pluck(:value)
    end
  end

end
