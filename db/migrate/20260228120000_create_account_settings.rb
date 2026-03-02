# frozen_string_literal: true

class CreateAccountSettings < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      create_table :account_settings do |t|
        t.bigint :account_id, null: false
        t.string :type, null: false
        t.text :value, null: false
        t.bigint :tenant_id
        t.timestamps
      end

      add_index :account_settings, [:account_id, :type], unique: true, name: 'index_account_settings_on_account_id_and_type'
      add_index :account_settings, :account_id, name: 'index_account_settings_on_account_id'
      add_index :account_settings, :tenant_id, name: 'index_account_settings_on_tenant_id'

      migrate_data
    end
  end

  def down
    drop_table :account_settings
  end

  private

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def migrate_data
    # Boolean settings: CAST to "1"/"0"
    boolean_settings = {
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

    # String settings
    string_settings = %i[
      bg_colour link_colour text_colour menu_bg_colour menu_link_colour
      content_bg_colour plans_tab_bg_colour plans_bg_colour content_border_colour
      link_label link_url favicon token_api cms_token
      cc_terms_path cc_privacy_path cc_refunds_path
      change_account_plan_permission change_service_plan_permission
      authentication_strategy janrain_api_key janrain_relying_party
      cas_server_url sso_key sso_login_url
      spam_protection_level admin_bot_protection_level product tracker_code
    ]

    # Text settings
    text_settings = %i[welcome_text refund_policy privacy_policy]

    # Switch settings
    switch_settings = %i[
      account_plans_switch service_plans_switch finance_switch
      require_cc_on_signup_switch multiple_services_switch multiple_applications_switch
      multiple_users_switch skip_email_engagement_footer_switch groups_switch
      branding_switch web_hooks_switch iam_tools_switch
    ]

    now = Time.current.to_fs(:db)

    # Migrate boolean settings
    boolean_settings.each do |col, _default|
      type_name = "AccountSetting::#{col.to_s.camelize}"
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
      SQL
    end

    # Migrate string settings
    string_settings.each do |col|
      type_name = "AccountSetting::#{col.to_s.camelize}"
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
      SQL
    end

    # Migrate text settings
    text_settings.each do |col|
      type_name = "AccountSetting::#{col.to_s.camelize}"
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
      SQL
    end

    # Migrate switch settings
    switch_settings.each do |col|
      type_name = "AccountSetting::#{col.to_s.camelize}"
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
      SQL
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
