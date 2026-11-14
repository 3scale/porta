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
    TestSettingsModel.delete_all
    ActiveRecord::Migration.verbose = true
  end

  test 'migrates boolean settings: true, false, and NULL' do
    legacy = TestSettingsModel.create_legacy!(
      account: @provider,
      forum_enabled: true,
      public_search: false,
      hide_service: nil
    )
    legacy.reload

    assert_equal true, legacy.forum_enabled
    assert_equal false, legacy.public_search
    assert_nil legacy.hide_service

    @migration.up

    records = @provider.account_settings.reload.index_by(&:class)

    assert_equal true, records[AccountSetting::ForumEnabled]&.value
    assert_equal false, records[AccountSetting::PublicSearch]&.value
    assert_equal false, records[AccountSetting::HideService]&.value, 'NULL boolean should be migrated as false'
    assert_equal @provider.tenant_id, records[AccountSetting::ForumEnabled].tenant_id
  end

  test 'migrates non-boolean settings, skipping empty strings and nil' do
    legacy = TestSettingsModel.create_legacy!(
      account: @provider,
      tracker_code: 'UA-abcdef',
      favicon: '',
      refund_policy: nil,
      finance_switch: 'visible',
      branding_switch: ''
    )
    legacy.reload

    assert_equal 'UA-abcdef', legacy.tracker_code
    assert_equal '', legacy.favicon
    assert_nil legacy.refund_policy
    assert_equal 'visible', legacy.finance_switch
    assert_equal '', legacy.branding_switch

    @migration.up

    records = @provider.account_settings.reload.index_by(&:class)

    assert_equal 'UA-abcdef', records[AccountSetting::TrackerCode]&.value
    assert_nil records[AccountSetting::Favicon], 'empty string should not be migrated'
    assert_nil records[AccountSetting::RefundPolicy], 'nil text should not be migrated'
    assert_equal 'visible', records[AccountSetting::FinanceSwitch]&.value
    assert_nil records[AccountSetting::BrandingSwitch], 'empty switch should not be migrated'
  end

  test 'handles multiple accounts independently' do
    provider2 = FactoryBot.create(:provider_account)
    provider2.account_settings.delete_all
    TestSettingsModel.where(account_id: provider2.id).delete_all

    TestSettingsModel.create_legacy!(account: @provider, tracker_code: 'UA-111111')
    TestSettingsModel.create_legacy!(account: provider2, tracker_code: 'UA-222222')

    @migration.up

    setting1 = @provider.account_settings.reload.find_by(type: 'TrackerCode')
    setting2 = provider2.account_settings.reload.find_by(type: 'TrackerCode')

    assert_equal 'UA-111111', setting1&.value
    assert_equal 'UA-222222', setting2&.value
  end

  test 'migrates all 41 legacy setting columns' do
    all_settings = {
      # Intentionally not migrated (dead columns):
      # heroku_id: 'heroku-id',
      # heroku_name: 'heroku-name',

      # Intentionally not migrated (unused settings, see PR #4375):
      # app_gallery_enabled: false,
      # documentation_enabled: true,
      # documentation_public: true,
      # strong_passwords_enabled: true,
      # can_create_service: true,
      # setup_fee_enabled: true,
      # bg_colour: '#112233',
      # link_colour: '#445566',
      # text_colour: '#778899',
      # menu_bg_colour: '#aabbcc',
      # menu_link_colour: '#ddeeff',
      # content_bg_colour: '#001122',
      # plans_tab_bg_colour: '#334455',
      # plans_bg_colour: '#667788',
      # content_border_colour: '#99aabb',
      # link_label: 'Docs',
      # link_url: 'https://example.com/docs',
      # token_api: 'token_api_val',
      # cms_token: 'cms_token_val',
      # janrain_api_key: 'janrain_key_val',
      # janrain_relying_party: 'janrain_rp_val',
      # product: 'connect',
      # welcome_text: 'Welcome developer!',

      # Booleans
      forum_enabled: true,
      anonymous_posts_enabled: true,
      signups_enabled: false,
      useraccountarea_enabled: false,
      forum_public: false,
      hide_service: true,
      monthly_charging_enabled: false,
      monthly_billing_enabled: true,
      public_search: true,
      account_plans_ui_visible: true,
      service_plans_ui_visible: true,
      cms_escape_draft_html: false,
      cms_escape_published_html: false,
      enforce_sso: true,
      # Strings
      favicon: 'https://example.com/favicon.ico',
      cc_terms_path: '/legal/terms',
      cc_privacy_path: '/legal/privacy',
      cc_refunds_path: '/legal/refunds',
      change_account_plan_permission: 'request',
      change_service_plan_permission: 'direct',
      authentication_strategy: 'cas',
      cas_server_url: 'https://cas.example.com',
      sso_key: 'sso_key_val',
      sso_login_url: 'https://sso.example.com/login',
      spam_protection_level: 'captcha',
      admin_bot_protection_level: 'captcha',
      tracker_code: 'UA-123456-7',
      # Texts
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

    records = @provider.account_settings.reload.index_by { _1.class.setting_name.to_sym }

    assert_equal all_settings.size, records.size

    all_settings.each do |field, expected|
      record = records.fetch(field) { flunk "missing AccountSetting for #{field}" }
      expected_str = case expected
                     when true then '1'
                     when false then '0'
                     else expected.to_s
                     end
      assert_equal expected_str, record.value_before_type_cast, "mismatch for #{field}"
    end
  end

  test 'is idempotent and handles existing records via ON DUPLICATE KEY UPDATE' do
    TestSettingsModel.create_legacy!(
      account: @provider,
      tracker_code: 'UA-ffffff',
      forum_enabled: true
    )

    @migration.up

    assert_no_changes -> { @provider.account_settings.reload.order(:id).map(&:attributes) } do
      @migration.up
    end
  end

  test 'down removes migrated settings but preserves other account_settings' do
    TestSettingsModel.create_legacy!(
      account: @provider,
      tracker_code: 'UA-abcdef',
      forum_enabled: true
    )
    @migration.up

    custom_setting = AccountSetting::CspHeaderAdmin.create!(
      account: @provider,
      value: "default-src 'self'",
      tenant_id: @provider.tenant_id
    )

    assert @provider.account_settings.reload.exists?(type: 'TrackerCode')
    assert @provider.account_settings.exists?(type: 'ForumEnabled')
    assert @provider.account_settings.exists?(id: custom_setting.id)

    @migration.down

    assert_not @provider.account_settings.reload.exists?(type: 'TrackerCode')
    assert_not @provider.account_settings.exists?(type: 'ForumEnabled')
    assert @provider.account_settings.exists?(id: custom_setting.id),
           'down must preserve non-migrated account_settings records'
  end
end
