# frozen_string_literal: true

module Sites::UsageRulesHelper
  def approval_required_editable_hint(account)
    t("formtastic.hints.settings.account_approval_required") + sso_hint(account)
  end

  def approval_required_disabled_hint(account)
    t("formtastic.hints.settings.approval_required_referer_html", link: link_to("Account Plans", admin_buyers_account_plans_path) ) + sso_hint(account)
  end

  def sso_hint(account)
    if account.authentication_providers.any?
      " #{t('sites.usage_rules.edit.sso_integrations_info_html', link: provider_admin_authentication_providers_path)}".html_safe
    else
      ''
    end
  end
end
