# frozen_string_literal: true

# Temporary script to compare legacy settings (from the `settings` table) against
# the new AccountSetting records for a given provider. Can be removed after 2.17 is released.
#
# Usage: rails runner script/compare_old_settings.rb <provider_id>

provider_id = ARGV[0]&.to_i
abort "Usage: rails runner script/compare_old_settings.rb <provider_id>" unless provider_id&.positive?

provider = Account.providers.find_by(id: provider_id)
abort "Provider #{provider_id} not found" unless provider

old_row = ActiveRecord::Base.connection.select_one("SELECT * FROM settings WHERE account_id = #{provider.id}")
abort "No legacy settings row for provider #{provider_id}" unless old_row

facade = provider.settings

BOOLEANS = %i[
  forum_enabled app_gallery_enabled anonymous_posts_enabled signups_enabled
  documentation_enabled useraccountarea_enabled documentation_public forum_public
  hide_service monthly_charging_enabled monthly_billing_enabled strong_passwords_enabled
  can_create_service public_search account_plans_ui_visible service_plans_ui_visible
  setup_fee_enabled cms_escape_draft_html cms_escape_published_html enforce_sso
].freeze

STRINGS = %i[
  bg_colour link_colour text_colour menu_bg_colour menu_link_colour
  content_bg_colour plans_tab_bg_colour plans_bg_colour content_border_colour
  link_label link_url favicon token_api cms_token
  cc_terms_path cc_privacy_path cc_refunds_path
  change_account_plan_permission change_service_plan_permission
  authentication_strategy janrain_api_key janrain_relying_party
  cas_server_url sso_key sso_login_url
  spam_protection_level admin_bot_protection_level product tracker_code
].freeze

TEXTS = %i[welcome_text refund_policy privacy_policy].freeze

SWITCHES = %i[
  account_plans_switch service_plans_switch finance_switch
  require_cc_on_signup_switch multiple_services_switch multiple_applications_switch
  multiple_users_switch skip_email_engagement_footer_switch groups_switch
  branding_switch web_hooks_switch iam_tools_switch
].freeze

mismatches = []
matches = 0

(BOOLEANS + STRINGS + TEXTS + SWITCHES).each do |col|
  old_val = old_row[col.to_s]

  new_val = if SWITCHES.include?(col)
              facade.public_send(col.to_s.delete_suffix("_switch"))&.value
            else
              facade.public_send(col)
            end

  # Normalize for comparison
  old_normalized = case old_val
                   when true, 1 then true
                   when false, 0 then false
                   when nil, "" then nil
                   else old_val.to_s
                   end

  new_normalized = case new_val
                   when true then true
                   when false then false
                   when Symbol then new_val.to_s
                   when nil then nil
                   else new_val.to_s
                   end

  # NULL/empty old booleans should map to false in new system
  if BOOLEANS.include?(col) && old_normalized.nil?
    old_normalized = false
  end

  # NULL/empty old strings/texts/switches should map to nil (default) in new system
  if !BOOLEANS.include?(col) && (old_normalized.nil? || old_normalized == "")
    old_normalized = nil
    new_normalized = nil if new_normalized == "" || new_normalized.nil?
  end

  if old_normalized == new_normalized
    matches += 1
  else
    mismatches << { field: col, old: old_val.inspect, new: new_val.inspect,
                    old_normalized: old_normalized.inspect, new_normalized: new_normalized.inspect }
  end
end

puts "Provider: #{provider_id} (#{provider.org_name})"
puts "Matches: #{matches}/#{BOOLEANS.size + STRINGS.size + TEXTS.size + SWITCHES.size}"

if mismatches.empty?
  puts "All settings match!"
else
  puts "\nMismatches (#{mismatches.size}):"
  mismatches.each do |m|
    puts "  #{m[:field]}: old=#{m[:old]} new=#{m[:new]}"
  end
end
