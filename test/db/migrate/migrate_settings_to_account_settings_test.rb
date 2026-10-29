# frozen_string_literal: true

require 'test_helper'
require Rails.root.join('db/migrate/20260620000000_migrate_settings_to_account_settings')

class MigrateSettingsToAccountSettingsTest < ActiveSupport::TestCase
  DEFAULT_NOT_NULL_SETTINGS = {
    multiple_applications_switch: 'hidden',
    multiple_users_switch: 'hidden',
    finance_switch: 'hidden',
    multiple_services_switch: 'hidden',
    groups_switch: 'hidden',
    account_plans_switch: 'hidden',
    service_plans_switch: 'hidden',
    branding_switch: 'hidden'
  }.freeze

  def setup
    @provider = FactoryBot.create(:provider_account)
    @provider.account_settings.delete_all
    @migration = MigrateSettingsToAccountSettings.new
    ActiveRecord::Base.connection.execute("DELETE FROM settings WHERE account_id = #{@provider.id}")
    ActiveRecord::Migration.verbose = false
  end

  def teardown
    ActiveRecord::Migration.verbose = true
  end

  test 'migrates boolean settings with true as 1 and false as 0, ignoring nil' do
    insert_legacy_settings(
      account_id: @provider.id,
      tenant_id: @provider.tenant_id,
      forum_enabled: true,
      app_gallery_enabled: false,
      signups_enabled: true,
      hide_service: nil
    )

    @migration.up

    records = @provider.account_settings.reload.index_by(&:class)

    assert_equal '1', records[AccountSetting::ForumEnabled]&.value
    assert_equal '0', records[AccountSetting::AppGalleryEnabled]&.value
    assert_equal '1', records[AccountSetting::SignupsEnabled]&.value
    assert_nil records[AccountSetting::HideService]
    assert_equal @provider.tenant_id, records[AccountSetting::ForumEnabled].tenant_id
  end

  test 'migrates string and text settings, skipping empty strings and nil' do
    insert_legacy_settings(
      account_id: @provider.id,
      tenant_id: @provider.tenant_id,
      bg_colour: '#abcdef',
      link_colour: '',
      sso_key: 'sso_secret_key_123',
      welcome_text: 'Welcome to our developer portal!',
      privacy_policy: '',
      refund_policy: nil
    )

    @migration.up

    records = @provider.account_settings.reload.index_by(&:class)

    assert_equal '#abcdef', records[AccountSetting::BgColour]&.value
    assert_nil records[AccountSetting::LinkColour], 'empty string should not be migrated'
    assert_equal 'sso_secret_key_123', records[AccountSetting::SSOKey]&.value
    assert_equal 'Welcome to our developer portal!', records[AccountSetting::WelcomeText]&.value
    assert_nil records[AccountSetting::PrivacyPolicy], 'empty text should not be migrated'
    assert_nil records[AccountSetting::RefundPolicy], 'nil text should not be migrated'
  end

  test 'migrates switch settings properly' do
    insert_legacy_settings(
      account_id: @provider.id,
      tenant_id: @provider.tenant_id,
      finance_switch: 'visible',
      multiple_services_switch: 'hidden',
      account_plans_switch: 'denied',
      branding_switch: ''
    )

    @migration.up

    records = @provider.account_settings.reload.index_by(&:class)

    assert_equal 'visible', records[AccountSetting::FinanceSwitch]&.value
    assert_equal 'hidden', records[AccountSetting::MultipleServicesSwitch]&.value
    assert_equal 'denied', records[AccountSetting::AccountPlansSwitch]&.value
    assert_nil records[AccountSetting::BrandingSwitch], 'empty switch should not be migrated'
  end

  test 'handles multiple accounts independently' do
    provider2 = FactoryBot.create(:provider_account)
    provider2.account_settings.delete_all
    ActiveRecord::Base.connection.execute("DELETE FROM settings WHERE account_id = #{provider2.id}")

    insert_legacy_settings(
      account_id: @provider.id,
      tenant_id: @provider.tenant_id,
      bg_colour: '#111111'
    )
    insert_legacy_settings(
      account_id: provider2.id,
      tenant_id: provider2.tenant_id,
      bg_colour: '#222222'
    )

    @migration.up

    setting1 = @provider.account_settings.reload.find_by(type: 'BgColour')
    setting2 = provider2.account_settings.reload.find_by(type: 'BgColour')

    assert_equal '#111111', setting1&.value
    assert_equal '#222222', setting2&.value
  end

  test 'migrates all 64 legacy setting columns and makes them accessible via Settings facade' do
    all_settings = {
      account_id: @provider.id,
      tenant_id: @provider.tenant_id,
      # Booleans
      forum_enabled: true,
      app_gallery_enabled: false,
      anonymous_posts_enabled: true,
      signups_enabled: false,
      documentation_enabled: true,
      useraccountarea_enabled: false,
      documentation_public: true,
      forum_public: false,
      hide_service: true,
      monthly_charging_enabled: false,
      monthly_billing_enabled: true,
      strong_passwords_enabled: true,
      can_create_service: true,
      public_search: true,
      account_plans_ui_visible: true,
      service_plans_ui_visible: true,
      setup_fee_enabled: true,
      cms_escape_draft_html: false,
      cms_escape_published_html: false,
      enforce_sso: true,
      # Strings
      bg_colour: '#112233',
      link_colour: '#445566',
      text_colour: '#778899',
      menu_bg_colour: '#aabbcc',
      menu_link_colour: '#ddeeff',
      content_bg_colour: '#001122',
      plans_tab_bg_colour: '#334455',
      plans_bg_colour: '#667788',
      content_border_colour: '#99aabb',
      link_label: 'Docs',
      link_url: 'https://example.com/docs',
      favicon: 'https://example.com/favicon.ico',
      token_api: 'token_api_val',
      cms_token: 'cms_token_val',
      cc_terms_path: '/legal/terms',
      cc_privacy_path: '/legal/privacy',
      cc_refunds_path: '/legal/refunds',
      change_account_plan_permission: 'request',
      change_service_plan_permission: 'direct',
      authentication_strategy: 'cas',
      janrain_api_key: 'janrain_key_val',
      janrain_relying_party: 'janrain_rp_val',
      cas_server_url: 'https://cas.example.com',
      sso_key: 'sso_key_val',
      sso_login_url: 'https://sso.example.com/login',
      spam_protection_level: 'captcha',
      admin_bot_protection_level: 'recaptcha_v3',
      product: 'connect',
      tracker_code: 'UA-123456-7',
      # Texts
      welcome_text: 'Welcome developer!',
      refund_policy: 'Full refund within 30 days',
      privacy_policy: 'We protect your data',
      # Switches
      account_plans_switch: 'visible',
      service_plans_switch: 'hidden',
      finance_switch: 'visible',
      require_cc_on_signup_switch: 'denied',
      multiple_services_switch: 'visible',
      multiple_applications_switch: 'visible',
      multiple_users_switch: 'hidden',
      skip_email_engagement_footer_switch: 'visible',
      groups_switch: 'denied',
      branding_switch: 'visible',
      web_hooks_switch: 'visible',
      iam_tools_switch: 'denied'
    }

    insert_legacy_settings(all_settings)

    @migration.up

    assert_equal 64, @provider.account_settings.reload.count

    facade = @provider.settings
    assert facade.forum_enabled
    assert_not facade.app_gallery_enabled
    assert_equal '#112233', facade.bg_colour
    assert_equal 'Welcome developer!', facade.welcome_text
    assert_equal 'visible', facade.finance.value
    assert facade.finance.visible?
    assert_equal 'request', facade.change_account_plan_permission
    assert_equal 'sso_key_val', facade.sso_key
    assert_equal 'cas', facade.authentication_strategy
  end

  test 'is idempotent and handles existing records via ON DUPLICATE KEY UPDATE' do
    insert_legacy_settings(
      account_id: @provider.id,
      tenant_id: @provider.tenant_id,
      bg_colour: '#ffffff',
      forum_enabled: true
    )

    @migration.up
    count_first_run = @provider.account_settings.reload.count

    assert_nothing_raised do
      @migration.up
    end

    assert_equal count_first_run, @provider.account_settings.reload.count
    assert_equal '#ffffff', @provider.account_settings.find_by(type: 'BgColour').value
  end

  test 'down removes migrated settings but preserves other account_settings' do
    insert_legacy_settings(
      account_id: @provider.id,
      tenant_id: @provider.tenant_id,
      bg_colour: '#abcdef',
      forum_enabled: true
    )
    @migration.up

    # Create an unrelated account setting (like an HTTP header)
    custom_setting = AccountSetting::CspHeaderAdmin.create!(
      account: @provider,
      value: "default-src 'self'",
      tenant_id: @provider.tenant_id
    )

    assert @provider.account_settings.reload.exists?(type: 'BgColour')
    assert @provider.account_settings.exists?(type: 'ForumEnabled')
    assert @provider.account_settings.exists?(id: custom_setting.id)

    @migration.down

    assert_not @provider.account_settings.reload.exists?(type: 'BgColour')
    assert_not @provider.account_settings.exists?(type: 'ForumEnabled')
    assert @provider.account_settings.exists?(id: custom_setting.id),
           'down must preserve non-migrated account_settings records'
  end

  private

  def insert_legacy_settings(attrs)
    attrs = DEFAULT_NOT_NULL_SETTINGS.merge(attrs)
    columns = attrs.keys.map(&:to_s)
    values = attrs.values.map do |val|
      case val
      when nil then 'NULL'
      when true then 'TRUE'
      when false then 'FALSE'
      when Numeric then val.to_s
      else
        ActiveRecord::Base.connection.quote(val.to_s)
      end
    end

    sql = "INSERT INTO settings (#{columns.join(', ')}) VALUES (#{values.join(', ')})"
    ActiveRecord::Base.connection.execute(sql)
  end
end
