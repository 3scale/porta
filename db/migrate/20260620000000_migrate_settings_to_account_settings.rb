# frozen_string_literal: true

# Migrates data from the legacy `settings` table (backed by the Settings AR model)
# into the new `account_settings` STI table (backed by AccountSetting subclasses).
#
# The `settings` table is intentionally left intact so the migration can be safely
# rolled back and so existing data is preserved for auditing purposes.
class MigrateSettingsToAccountSettings < ActiveRecord::Migration[7.2]
  def up
    now = Time.current.to_fs(:db)

    # Booleans: NULL → '0' (false). CASE handles this without a WHERE filter.
    boolean_settings.each do |col|
      bool_value = System::Database.oracle? ? "CASE WHEN s.#{col} = 1 THEN '1' ELSE '0' END"
                                            : "CASE WHEN s.#{col} = TRUE THEN '1' ELSE '0' END"
      upsert_setting(col, bool_value, now)
    end

    # Strings, texts, and switches: skip NULLs and empty strings.
    # On Oracle '' IS NULL, so IS NOT NULL alone covers both.
    (string_settings + text_settings + switch_settings).each do |col|
      upsert_setting(col, "s.#{col}", now, where: non_empty_condition(col))
    end
  end

  def down
    # We only remove the rows that were migrated from the settings table; any rows
    # created directly via the new system (e.g. http_headers) are left untouched.
    migrated_types = all_columns.map { |col| resolve_sti_name(col) }
    AccountSetting.where(type: migrated_types).delete_all
  end

  private

  def upsert_setting(col, value_expr, now, where: nil)
    type_name = resolve_sti_name(col)
    where_clause = where ? "WHERE #{where}" : "WHERE 1=1"

    conflict_clause = if System::Database.mysql?
                        "ON DUPLICATE KEY UPDATE account_settings.updated_at = account_settings.updated_at"
                      elsif System::Database.oracle?
                        "AND NOT EXISTS (SELECT 1 FROM account_settings a WHERE a.account_id = s.account_id AND a.type = '#{type_name}')"
                      else
                        "ON CONFLICT (account_id, type) DO NOTHING"
                      end

    # Oracle has no id column default, ActiveRecord takes ids from the table's sequence
    id_column, id_value = System::Database.oracle? ? ['id, ', "#{AccountSetting.sequence_name}.NEXTVAL, "] : []

    safety_assured do
      execute <<~SQL.squish
        INSERT INTO account_settings (#{id_column}account_id, type, value, tenant_id, created_at, updated_at)
        SELECT #{id_value}s.account_id, '#{type_name}', #{value_expr}, s.tenant_id, '#{now}', '#{now}'
        FROM settings s #{where_clause}
        #{conflict_clause}
      SQL
    end
  end

  # Oracle treats '' as NULL, so IS NOT NULL alone covers both.
  def non_empty_condition(col)
    if System::Database.oracle?
      "s.#{col} IS NOT NULL"
    else
      "s.#{col} IS NOT NULL AND s.#{col} != ''"
    end
  end

  def resolve_sti_name(col)
    "AccountSetting::#{col.to_s.camelize}".constantize.sti_name
  end

  def all_columns
    boolean_settings + string_settings + text_settings + switch_settings
  end

  # Deliberately not migrated: heroku_id, heroku_name and unused settings (app_gallery_enabled, documentation_enabled,
  # documentation_public, strong_passwords_enabled, can_create_service, setup_fee_enabled, *_colour, link_label,
  # link_url, token_api, cms_token, janrain_api_key, janrain_relying_party, product, welcome_text).
  def boolean_settings
    %i[
      forum_enabled anonymous_posts_enabled signups_enabled useraccountarea_enabled forum_public
      hide_service monthly_charging_enabled monthly_billing_enabled public_search
      account_plans_ui_visible service_plans_ui_visible
      cms_escape_draft_html cms_escape_published_html enforce_sso
    ]
  end

  def string_settings
    %i[
      favicon cc_terms_path cc_privacy_path cc_refunds_path
      change_account_plan_permission change_service_plan_permission
      authentication_strategy cas_server_url sso_key sso_login_url
      spam_protection_level admin_bot_protection_level tracker_code
    ]
  end

  def text_settings
    %i[refund_policy privacy_policy]
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
