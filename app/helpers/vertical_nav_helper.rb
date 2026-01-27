# rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/ModuleLength, Rails/HelperInstanceVariable
# frozen_string_literal: true

module VerticalNavHelper
  include PlansHelper

  def vertical_nav_data
    {
      'current-api': (current_api.to_json(root: false, only: %i[name]) if %i[serviceadmin backend_api].include?(active_menu)),
      sections: vertical_nav_sections.to_json,
      'active-section': active_submenu,
      'active-item': active_sidebar
    }.compact
  end

  def vertical_nav_sections
    case active_menu
    when :personal, :account
      account_nav_sections
    when :buyers, :finance, :cms, :site, :settings, :audience
      audience_nav_sections
    when :apis, :applications, :active_docs
      active_docs_and_alerts_nav_sections
    when :serviceadmin, :monitoring
      service_nav_sections
    when :backend_api
      backend_api_nav_sections
    end
  end

  # Account
  def account_nav_sections
    sections = []
    sections << {id: :overview, title: 'Overview', path: provider_admin_account_path} if can?(:manage, current_account)
    sections << {id: :personal, title: 'Personal', items: account_personal_items}     if can?(:manage, current_user)

    if can? :manage, current_account
      sections << {id: :users,         title: 'Users',         items: account_users_items}
      sections << {id: :billing,       title: 'Billing',       items: account_billing_items} if ThreeScale.master_billing_enabled? && !current_account.master?
    end

    sections << {id: :integrate,            title: 'Integrate',            items: account_itegrate_items}
    sections << {id: :email_configurations, title: 'Email configurations', path: provider_admin_account_email_configurations_path} if current_account.master? && Features::EmailConfigurationConfig.enabled?
    sections << {id: :export,               title: 'Export',               path: new_provider_admin_account_data_exports_path} if can? :export, :data
    sections
  end

  def account_personal_items
    items = []
    items << {id: :personal_details,         title: 'Personal Details',         path: edit_provider_admin_user_personal_details_path}     if can?(:manage, current_user)
    items << {id: :tokens,                   title: 'Tokens',                   path: provider_admin_user_access_tokens_path}
    items << {id: :notification_preferences, title: 'Notification Preferences', path: provider_admin_user_notification_preferences_path}  if can?(:show, current_user.notification_preferences)
    items
  end

  def account_users_items
    items = []

    if can? :manage, User
      items << {id: :listing,     title: 'Listing',     path: provider_admin_account_users_path}
      items << {id: :invitations, title: 'Invitations', path: provider_admin_account_invitations_path} if can?(:manage, :multiple_users) && !current_account.settings.enforce_sso?
    end

    items << {id: :sso_integrations, title: 'SSO Integrations', path: provider_admin_account_authentication_providers_path} if current_account.provider_can_use? :provider_sso
    items
  end

  def account_billing_items
    items = []
    items << {id: :invoices,        title: '3scale Invoices', path: provider_admin_account_invoices_path}       if can?(:read, Invoice) && !ThreeScale.config.onpremises
    items << {id: :payment_details, title: 'Payment Details', path: provider_admin_account_braintree_blue_path} if can?(:manage, :credit_card) && !ThreeScale.config.onpremises
    items
  end

  def account_itegrate_items
    items = []
    items << {id: :webhooks,  title: 'Webhooks',        path: edit_provider_admin_webhooks_path} if can? :manage, :web_hooks
    items << {id: :apidocs,   title: '3scale API Docs', path: provider_admin_api_docs_path}
    items << {id: :bot_protection,  title: 'Bot Protection',  path: edit_provider_admin_bot_protection_path}
  end

  # Audience
  def audience_nav_sections
    sections = []
    sections << {id: :accounts,     title: 'Accounts',         items: audience_accounts_items}      if can?(:manage, :partners) || can?(:manage, :settings)
    sections << {id: :applications, title: 'Applications',     items: audience_applications_items}  if can?(:manage, :applications)
    sections << {id: :finance,      title: 'Billing',          items: audience_billing_items}       if can?(:see, :finance) && (can?(:manage, :finance) || can?(:manage, :settings))
    sections << {id: :cms,          title: 'Developer Portal', items: audience_portal_items}        if (can?(:manage, :portal) || can?(:manage, :settings) || can?(:manage, :plans)) && !master_on_premises?
    sections << {id: :messages,     title: 'Messages',         items: audience_messages_items}
    sections
  end

  def audience_accounts_items
    items = []
    items << {id: :listing,       title: 'Listing',       path: admin_buyers_accounts_path}           if can?(:manage, :partners)
    items << {id: :account_plans, title: 'Account Plans', path: admin_buyers_account_plans_path}     if account_plans_management_visible?
    items << {id: :subscriptions, title: 'Subscriptions', path: admin_buyers_service_contracts_path}  if service_plans_management_visible?

    if can?(:manage, :settings)
      items << { title: 'Settings', subItems: [
        { id: :usage_rules,         title: 'Usage Rules',        path: edit_admin_site_usage_rules_path },
        { id: :fields_definitions,  title: 'Fields Definitions', path: admin_fields_definitions_path }
      ]}
    end

    items
  end

  def audience_applications_items
    items = []
    items << {id: :listing, title: 'Listing', path: provider_admin_applications_path} if can?(:manage, :partners)
    items << {id: :alerts,  title: 'Alerts',  path: admin_alerts_path}                if can?(:manage, :monitoring)
    items
  end

  def audience_billing_items
    items = []

    if can?(:manage, :finance)
      items << {id: :earnings,    title: t('shared.nav.earnings'), path: admin_finance_root_path}
      items << {id: :invoices,    title: 'Invoices',               path: admin_finance_invoices_path}
      items << {id: :log_entries, title: 'Finance Log',            path: admin_finance_log_entries_path} if current_user.impersonation_admin?
    end

    if can?(:manage, :settings)
      billing_settings_items = []
      # this setting needs more than just editing auth, as such it's not a setting
      billing_settings_items << {id: :charging_and_gateway, title: 'Charging & Gateway',   path: admin_finance_settings_path} if can?(:manage, :finance)
      billing_settings_items << {id: :credit_card_policies, title: 'Credit Card Policies', path: edit_admin_site_settings_path}

      items << { title: 'Settings', subItems: billing_settings_items }
    end

    items
  end

  def audience_portal_items # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    items = []

    if can?(:manage, :portal)
      items << {id: :content,            title: 'Content',            path: provider_admin_cms_templates_path}
      items << {id: :changes,            title: 'Drafts',             path: provider_admin_cms_changes_path}
      items << {id: :redirects,          title: 'Redirects',          path: provider_admin_cms_redirects_path}
      items << {id: :groups,             title: 'Groups',             path: provider_admin_cms_groups_path}        if can?(:see, :groups)
      items << {id: :logo,               title: 'Logo',               path: edit_provider_admin_account_logo_path} if can?(:update, :logo)
      items << {id: :feature_visibility, title: 'Feature Visibility', path: provider_admin_cms_switches_path}
      # FIXME: should be a link not a href
      items << {id: :ActiveDocs,         title: 'ActiveDocs',         path: admin_api_docs_services_path}          if can?(:manage, :plans)

      items << {id: 'separator 0'} # Separator
      items << {title: 'Visit Portal', path: provider_admin_cms_visit_portal_path.html_safe, target: '_blank'}
      items << {id: 'separator 1'} # Separator

      items << { title: 'Legal Terms', subItems: [
        {id: :signup_licence,               title: 'Signup',               path: edit_legal_terms_url(CMS::Builtin::LegalTerm::SIGNUP_SYSTEM_NAME)},
        {id: :service_subscription_licence, title: 'Service Subscription', path: edit_legal_terms_url(CMS::Builtin::LegalTerm::SUBSCRIPTION_SYSTEM_NAME)},
        {id: :new_application_licence,      title: 'New Application',      path: edit_legal_terms_url(CMS::Builtin::LegalTerm::NEW_APPLICATION_SYSTEM_NAME)}
      ]}
    end

    if can?(:manage, :settings)
      portal_settings_items = []
      portal_settings_items << {id: :admin_site_dns,   title: 'Domains & Access', path: admin_site_dns_path}
      portal_settings_items << {id: :spam_protection,  title: 'Bot Protection',  path: edit_admin_site_spam_protection_path}
      portal_settings_items << {id: :xss_protection,   title: 'XSS Protection',   path: edit_admin_site_developer_portal_path} if current_account.show_xss_protection_options?
      portal_settings_items << {id: :sso_integrations, title: 'SSO Integrations', path: provider_admin_authentication_providers_path}

      items << { title: 'Settings', subItems: portal_settings_items }
    end

    items << { title: 'Docs', subItems: [
      { id: :liquid_reference, title: 'Liquid Reference', path: provider_admin_liquid_docs_path },
    ]}
  end

  def audience_messages_items
    items = []
    items << {id: :inbox,         title: 'Inbox',         path: provider_admin_messages_root_path}
    items << {id: :sent_messages, title: 'Sent messages', path: provider_admin_messages_outbox_index_path}
    items << {id: :trash,         title: 'Trash',         path: provider_admin_messages_trash_index_path}

    if can?(:manage, :settings) && !master_on_premises?
      items << { title: 'Settings', subItems: [
        { id: :email,     title: 'Support emails',  path: edit_admin_site_emails_path },
        { id: :templates, title: 'Email Templates', path: provider_admin_cms_email_templates_path }
      ]}
    end

    items
  end

  # Service
  def service_nav_sections
    sections = []
    return sections unless @service

    can_manage_plans = can? :manage, :plans

    sections << {id: :overview,      title: 'Product Overview',      path: admin_service_path(@service)} if can_manage_plans
    sections << {id: :monitoring,    title: 'Analytics',     items: service_analytics}           if can? :manage, :monitoring
    sections << {id: :applications,  title: 'Applications',  items: service_applications}        if can_manage_plans || can?(:manage, :applications)
    sections << {id: :subscriptions, title: 'Subscriptions', items: service_subscriptions}       if can?(:manage, :service_plans) && current_account.settings.service_plans_ui_visible?

    sections << {id: :ActiveDocs,  title: 'ActiveDocs',  path: admin_service_api_docs_path(@service)} if can_manage_plans

    if can_manage_plans || can?(:manage, :policy_registry)
      # do not show out of date icon if the user can't promote (i.e. can't manage plans)
      out_of_date = can_manage_plans ? out_of_date_config?(@service) : nil
      sections << {id: :integration, title: 'Integration', items: service_integration_items, outOfDateConfig: out_of_date }
    end

    sections
  end

  def service_analytics
    items = []
    items << {id: :usage,              title: 'Traffic',            path: admin_service_stats_usage_path(@service)}
    items << {id: :daily_averages,     title: 'Daily Averages',     path:   admin_service_stats_days_path(@service)}
    items << {id: :hourly,             title: 'Hourly Averages',    path: admin_service_stats_hours_path(@service)}
    items << {id: :top_applications,   title: 'Top Applications',   path: admin_service_stats_top_applications_path(@service)}
    items << {id: :response_codes,     title: 'Response Codes',     path:   admin_service_stats_response_codes_path(@service)}
    items << {id: :alerts,             title: 'Alerts',             path: admin_service_alerts_path(@service)}
    items << {id: :errors,             title: 'Integration Errors', path: admin_service_errors_path(@service)} if can? :manage, :plans
    items
  end

  def service_applications
    items = []
    items << {id: :listing,           title: 'Listing',           path: admin_service_applications_path(@service)}      if can? :manage, :applications
    items << {id: :application_plans, title: 'Application Plans', path: admin_service_application_plans_path(@service)} if can?(:manage, :plans)
    if can?(:manage, :plans) && !master_on_premises?
      items << { title: 'Settings', subItems: [
        { id: :usage_rules, title: 'Usage Rules', path: usage_rules_admin_service_path(@service) }
      ]}
    end
    items
  end

  def service_subscriptions
    items = []
    items << {id: :subscriptions, title: 'Service Subscriptions', path: admin_buyers_service_contracts_path(search: {service_id: @service.id})}
    items << {id: :service_plans, title: 'Service Plans',         path: admin_service_service_plans_path(@service)}
  end

  def service_integration_items
    items = []
    if can?(:manage, :plans)
      items << {id: :configuration,       title: 'Configuration',     path: admin_service_integration_path(@service), itemOutOfDateConfig: out_of_date_config?(@service)}
      items << {id: :methods_metrics,     title: 'Methods and Metrics', path: admin_service_metrics_path(@service)}
      items << {id: :mapping_rules,       title: 'Mapping Rules',     path: admin_service_proxy_rules_path(@service)}
    end
    if @service.can_use_policies? && (can?(:manage, :plans) || can?(:manage, :policy_registry))
      items << {id: :policies,            title: 'Policies',          path: edit_admin_service_policies_path(@service)} if @service.can_use_policies?
    end
    if can?(:manage, :plans)
      items << {id: :backend_api_configs, title: 'Backends',        path: admin_service_backend_usages_path(@service)} if @service.can_use_backends?
      items << {id: :settings,            title: 'Settings',        path: settings_admin_service_path(@service)}
    end
    items
  end

  # Backend APIs
  def backend_api_nav_sections
    sections = []
    return sections unless @backend_api&.persisted?

    sections << {id: :overview,         title: 'Backend Overview',             path: provider_admin_backend_api_path(@backend_api)}
    sections << {id: :monitoring,       title: 'Analytics',            path: provider_admin_backend_api_stats_usage_path(@backend_api)} if can? :manage, :monitoring
    sections << {id: :methods_metrics,  title: 'Methods and Metrics',  path: provider_admin_backend_api_metrics_path(@backend_api)} if can? :edit, BackendApi
    sections << {id: :mapping_rules,    title: 'Mapping Rules',        path: provider_admin_backend_api_mapping_rules_path(@backend_api)} if can? :edit, BackendApi
    sections
  end

  # Others
  def active_docs_and_alerts_nav_sections
    sections = []
    sections << {id: :activedocs, title: 'ActiveDocs', path: admin_api_docs_services_path} if can? :manage, :partners
    sections << {id: :alerts,     title: 'Alerts',     path: admin_alerts_path }           if can?(:manage, :monitoring) && current_user.multiple_accessible_services?
    sections
  end

  private

  def out_of_date_config?(service)
    return false unless service

    service.pending_affecting_changes?
  end
end

# rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/ModuleLength, Rails/HelperInstanceVariable
