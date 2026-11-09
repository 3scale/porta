# frozen_string_literal: true

require 'test_helper'
require Rails.root.join('db/migrate/20260620000000_migrate_settings_to_account_settings')

class MigrateSettingsToAccountSettingsTest < ActiveSupport::TestCase
  class TestSettingsModel < ApplicationRecord
    self.table_name = 'settings'
    belongs_to :account

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

    def self.create_legacy!(account:, **attrs)
      create!(
        {
          account_id: account.id,
          tenant_id: account.tenant_id
        }.merge(DEFAULT_NOT_NULL_SETTINGS).merge(attrs)
      )
    end
  end

  def setup
    @provider = FactoryBot.create(:provider_account)
    @provider.account_settings.delete_all
    @migration = MigrateSettingsToAccountSettings.new
    TestSettingsModel.where(account_id: @provider.id).delete_all
    ActiveRecord::Migration.verbose = false
  end

  def teardown
    TestSettingsModel.where(account_id: @provider.id).delete_all if @provider
    ActiveRecord::Migration.verbose = true
  end

  test 'migrates boolean settings with true as 1 and false as 0, ignoring nil' do
    TestSettingsModel.create_legacy!(
      account: @provider,
      forum_enabled: true,
      app_gallery_enabled: false,
      signups_enabled: true,
      hide_service: nil
    )

    @migration.up

    records = @provider.account_settings.reload.index_by(&:class)

    assert_equal true, records[AccountSetting::ForumEnabled]&.value
    assert_equal false, records[AccountSetting::AppGalleryEnabled]&.value
    assert_equal true, records[AccountSetting::SignupsEnabled]&.value
    assert_equal '1', records[AccountSetting::ForumEnabled]&.value_before_type_cast
    assert_equal '0', records[AccountSetting::AppGalleryEnabled]&.value_before_type_cast
    assert_equal '1', records[AccountSetting::SignupsEnabled]&.value_before_type_cast
    assert_equal false, records[AccountSetting::HideService]&.value, 'NULL boolean should be migrated as false'
    assert_equal '0', records[AccountSetting::HideService]&.value_before_type_cast
    assert_equal @provider.tenant_id, records[AccountSetting::ForumEnabled].tenant_id
  end

  test 'migrates string and text settings, skipping empty strings and nil' do
    TestSettingsModel.create_legacy!(
      account: @provider,
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
    TestSettingsModel.create_legacy!(
      account: @provider,
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
    TestSettingsModel.where(account_id: provider2.id).delete_all

    TestSettingsModel.create_legacy!(
      account: @provider,
      bg_colour: '#111111'
    )
    TestSettingsModel.create_legacy!(
      account: provider2,
      bg_colour: '#222222'
    )

    @migration.up

    setting1 = @provider.account_settings.reload.find_by(type: 'BgColour')
    setting2 = provider2.account_settings.reload.find_by(type: 'BgColour')

    assert_equal '#111111', setting1&.value
    assert_equal '#222222', setting2&.value
  ensure
    TestSettingsModel.where(account_id: provider2.id).delete_all if provider2
  end

  test 'migrates all 64 legacy setting columns and makes them accessible via Settings facade' do
    all_settings = {
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

    TestSettingsModel.create_legacy!(account: @provider, **all_settings)

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
    TestSettingsModel.create_legacy!(
      account: @provider,
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
    TestSettingsModel.create_legacy!(
      account: @provider,
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
end
