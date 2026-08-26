# frozen_string_literal: true

# Migrates data from the legacy `settings` table (backed by the Settings AR model)
# into the new `account_settings` STI table (backed by AccountSetting subclasses).
#
# The `settings` table is intentionally left intact so the migration can be safely
# rolled back and so existing data is preserved for auditing purposes.
class MigrateSettingsToAccountSettings < ActiveRecord::Migration[7.2]
  def up
    safety_assured { migrate_data }
  end

  def down
    # Reversing this migration would delete all migrated account_settings records.
    # We only remove the rows that were migrated from the settings table; any rows
    # created directly via the new system (e.g. http_headers) are left untouched.
    migrated_types = (boolean_settings.keys + string_settings + text_settings + switch_settings)
      .map { |col| col.to_s.camelize }
    execute <<~SQL.squish
      DELETE FROM account_settings WHERE type IN (#{migrated_types.map { |t| "'#{t}'" }.join(', ')})
    SQL
  end

  private

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def migrate_data
    now = Time.current.to_fs(:db)

    # Boolean settings: stored as "1"/"0"
    boolean_settings.each_key do |col|
      type_name = col.to_s.camelize
      execute <<~SQL.squish
        INSERT INTO account_settings (account_id, type, value, tenant_id, created_at, updated_at)
        SELECT account_id,
               '#{type_name}',
               CASE WHEN #{col} = TRUE THEN '1' ELSE '0' END,
               tenant_id,
               '#{now}',
               '#{now}'
        FROM settings
        WHERE #{col} IS NOT NULL
        ON DUPLICATE KEY UPDATE account_settings.updated_at = account_settings.updated_at
      SQL
    end

    # String settings: skip NULL and empty strings
    string_settings.each do |col|
      type_name = col.to_s.camelize
      execute <<~SQL.squish
        INSERT INTO account_settings (account_id, type, value, tenant_id, created_at, updated_at)
        SELECT account_id,
               '#{type_name}',
               #{col},
               tenant_id,
               '#{now}',
               '#{now}'
        FROM settings
        WHERE #{col} IS NOT NULL AND #{col} != ''
        ON DUPLICATE KEY UPDATE account_settings.updated_at = account_settings.updated_at
      SQL
    end

    # Text settings: skip NULL and empty strings
    text_settings.each do |col|
      type_name = col.to_s.camelize
      execute <<~SQL.squish
        INSERT INTO account_settings (account_id, type, value, tenant_id, created_at, updated_at)
        SELECT account_id,
               '#{type_name}',
               #{col},
               tenant_id,
               '#{now}',
               '#{now}'
        FROM settings
        WHERE #{col} IS NOT NULL AND #{col} != ''
        ON DUPLICATE KEY UPDATE account_settings.updated_at = account_settings.updated_at
      SQL
    end

    # Switch settings: skip NULL and empty strings
    switch_settings.each do |col|
      type_name = col.to_s.camelize
      execute <<~SQL.squish
        INSERT INTO account_settings (account_id, type, value, tenant_id, created_at, updated_at)
        SELECT account_id,
               '#{type_name}',
               #{col},
               tenant_id,
               '#{now}',
               '#{now}'
        FROM settings
        WHERE #{col} IS NOT NULL AND #{col} != ''
        ON DUPLICATE KEY UPDATE account_settings.updated_at = account_settings.updated_at
      SQL
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def boolean_settings
    {
      forum_enabled: true,
      app_gallery_enabled: false,
      anonymous_posts_enabled: false,
      signups_enabled: true,
      documentation_enabled: true,
      useraccountarea_enabled: true,
      documentation_public: true,
      forum_public: true,
      hide_service: false,
      monthly_charging_enabled: true,
      monthly_billing_enabled: true,
      strong_passwords_enabled: false,
      can_create_service: false,
      public_search: false,
      account_plans_ui_visible: false,
      service_plans_ui_visible: false,
      setup_fee_enabled: false,
      cms_escape_draft_html: true,
      cms_escape_published_html: true,
      enforce_sso: false
    }
  end

  def string_settings
    %i[
      bg_colour link_colour text_colour menu_bg_colour menu_link_colour
      content_bg_colour plans_tab_bg_colour plans_bg_colour content_border_colour
      link_label link_url favicon token_api cms_token
      cc_terms_path cc_privacy_path cc_refunds_path
      change_account_plan_permission change_service_plan_permission
      authentication_strategy janrain_api_key janrain_relying_party
      cas_server_url sso_key sso_login_url
      spam_protection_level admin_bot_protection_level product tracker_code
    ]
  end

  def text_settings
    %i[welcome_text refund_policy privacy_policy]
  end

  def switch_settings
    %i[
      account_plans_switch service_plans_switch finance_switch
      require_cc_on_signup_switch multiple_services_switch multiple_applications_switch
      multiple_users_switch skip_email_engagement_footer_switch groups_switch
      branding_switch web_hooks_switch iam_tools_switch
    ]
  end
end
