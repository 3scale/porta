# frozen_string_literal: true

module Sites::UsageRulesHelper
  def account_approval_required_hint(account)
    hint = if account.settings.approval_required_editable?
             t('formtastic.hints.settings.account_approval_required')
           else
             t('formtastic.hints.settings.approval_required_referer', link: link_to('Account Plans', admin_buyers_account_plans_path))
           end

    if account.authentication_providers.any? # rubocop:disable Style/IfUnlessModifier
      hint += " #{t('sites.usage_rules.edit.sso_integrations_info_html', link: provider_admin_authentication_providers_path)}"
    end

    hint.html_safe # rubocop:disable Rails/OutputSafety
  end
end
