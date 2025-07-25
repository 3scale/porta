# frozen_string_literal: true

# rubocop:disable Style/PerlBackrefs
World(Module.new do
  break unless defined?(DeveloperPortal)

  include System::UrlHelpers.cms_url_helpers

  def provider_first_service!
    @provider.first_service!
  end

  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name, *args) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    case page_name

    # Public
    when /the home\s?page/
      '/'

    when /^the sign up page for the "([^"]*)" plan$/
      plan = Plan.find_by_name!($1)
      signup_path(:'plan_ids[]' => plan.id)

    when /the sign ?up page/,
         'the old multiapps sign up page',
         'the signup page'
      signup_path

    when 'the provider sign up page'
      provider_signup_path

    when 'the provider login page'
      provider_login_path

    when 'the provider onboarding wizard page'
      provider_admin_onboarding_wizard_intro_path

    when 'the login page'
      login_path

    when /^the login page on ([a-z0-9\.\-]+)$/
      login_url(:host => $1)

    when 'logout'
      logout_path

    when 'the provider reset password page'
      reset_provider_password_path

    when 'the forgot password page'
      new_admin_account_password_path

    when 'the support page'
      '/support'

    when 'the password page with invalid password reset token'
      admin_account_password_path(:password_reset_token => 'bogus')

    when 'the provider password page with invalid password reset token'
      provider_password_path(:password_reset_token => 'bogus')

    when 'the billing information wizard page'
      edit_provider_admin_account_path(next_step: 'credit_card')

    #
    # Messages - Admin portal
    #

    when "the provider inbox page"
      provider_admin_messages_root_path

    when "the provider sent messages page"
      provider_admin_messages_outbox_index_path

    when /^the provider page of message with subject "([^"]*)"$/
      message = @provider.sent_messages.find_by(subject: Regexp.last_match(1))
      provider_admin_messages_outbox_path(message)

    when "the outbox compose page"
      new_provider_admin_messages_outbox_path

    #
    # Messages - buyer side
    #
    when "the compose page"
      new_admin_messages_outbox_path

    when "the inbox page"
      admin_messages_root_path

    when "the outbox page"
      admin_messages_outbox_index_path
    when "the inbox show page"
      account = Account.first
      message = account.messages.build(body: 'foo', subject: 'bar')
      message.to current_account
      message.deliver
      admin_messages_inbox_path(message.recipients[0])

    when "the outbox show page"
      message = current_account.messages.build(body: 'foo', subject: 'bar')
      message.to = current_account
      message.save
      admin_messages_outbox_path(message)

    when "the trash page"
      admin_messages_trash_index_path

    when "the trash show page"
      account = Account.first
      message = account.messages.build(body: 'foo', subject: 'bar')
      message.to current_account
      message.deliver
      message = current_account.received_messages.last
      message.hide!

      admin_messages_trash_path(message)

    #
    # Forum
    #
    when 'forum settings',
         'the forum settings page'
      edit_admin_site_forum_path

    when 'the forum page'
      forum_path
    when 'the new topic page'
      new_forum_topic_path
    when /^the "([^"]*)" topic page$/
      forum_topic_path(Topic.find_by_title!($1))
    when 'the forum subscriptions page'
      forum_subscriptions_path

    #
    # Logged in
    #
    when /the dashboard( page)?/
      admin_dashboard_path

    when 'the provider dashboard'
      provider_admin_dashboard_path

    when 'search',
         'the search page'
      search_path

    #
    # Account settings (Admin portal)
    #
    when 'the account page',
          'settings'
      admin_account_path

    when 'the account edit page'
      edit_admin_account_path

    when 'the provider account page'
      provider_admin_account_path

    when 'the new provider account page'
      new_provider_admin_account_path

    when 'the provider personal page',
         'the provider personal details page'
      edit_provider_admin_user_personal_details_path

    when 'the provider edit account page',
         'the provider account edit page'
      edit_provider_admin_account_path

    when 'the edit credit card details page',
         'the braintree edit credit card details page'
      edit_admin_account_braintree_blue_path
    when 'the credit card details page'
      admin_account_payment_details_path
    when 'the provider braintree credit card details page'
      provider_admin_account_braintree_blue_path
    when 'the provider braintree edit credit card details page'
      edit_provider_admin_account_braintree_blue_path

    when 'the braintree credit card details page'
      admin_account_braintree_blue_path
    when 'the stripe credit card details page'
      admin_account_stripe_path
    when 'the stripe edit credit card details page'
      edit_admin_account_stripe_path
    when 'the personal details page'
      admin_account_personal_details_path
    when 'the provider users page'
      provider_admin_account_users_path
    when 'the users page'
      admin_account_users_path
    when /^the provider user edit page for "([^"]*)"$/
      user = User.find_by_username!($1)
      edit_provider_admin_account_user_path(user)
    when /^the user edit page for "([^"]*)"$/
      user = User.find_by_username!($1)
      edit_admin_account_user_path(user)
    when 'the new invitation page'
      new_admin_account_invitation_path
    when 'the provider new invitation page'
      new_provider_admin_account_invitation_path
    when 'the provider sent invitations page'
      provider_admin_account_invitations_path
    when 'the edit provider logo page'
      edit_provider_admin_account_logo_path
    when 'the email configurations page'
      provider_admin_account_email_configurations_path
    when 'the new email configurations page'
      new_provider_admin_account_email_configurations_path

    when 'the personal tokens page'
      provider_admin_user_access_tokens_path

    when 'the new access token page'
      new_provider_admin_user_access_token_path

    when /^(access token "(.*)"|the access token's) edit page$/
      access_token = AccessToken.find_by(name: $2) || @access_token
      edit_provider_admin_user_access_token_path(access_token)

    when 'the notification preferences page'
      provider_admin_user_notification_preferences_path

    #
    # Account management (Dev portal)
    #
    when 'the sent invitations page'
      admin_account_invitations_path

    #
    # SSO Integrations (Admin portal)
    #
    when 'the users sso integrations page'
      provider_admin_account_authentication_providers_path
    when 'the sso integration page'
      auth_provider = AuthenticationProvider.last
      provider_admin_account_authentication_provider_path(auth_provider)
    when 'the new sso integration page'
      new_provider_admin_account_authentication_provider_path
    when 'the edit rh sso integration page'
      edit_provider_admin_account_authentication_provider_path(@rhsso_integration)

      #
      # SSO Integrations (Dev portal)
      #
    when 'the developer portal users sso integrations page'
      provider_admin_authentication_providers_path
    when 'the developer portal sso integration page'
      auth_provider = AuthenticationProvider.last
      provider_admin_authentication_provider_path(auth_provider)
    when /^the developer portal new sso integration page for "([^"]*)"$/
      new_provider_admin_authentication_provider_path(kind: $1)
    when 'the developer portal edit integration page'
      auth_provider = AuthenticationProvider.last
      edit_provider_admin_authentication_provider_path(auth_provider)
    when 'the developer portal edit rh sso integration page'
      edit_provider_admin_authentication_provider_path(@rhsso_dev_portal_integration)
    when 'the developer portal edit auth0 integration page'
      edit_provider_admin_authentication_provider_path(@auth0_dev_portal_integration)

    #
    # ActiveDocs (Admin portal)
    #
    when /the ActiveDocs page/
      admin_api_docs_services_path
    when /the new ActiveDocs spec page/
      new_admin_api_docs_service_path
    when /the spec's preview page from Audience context/
      spec = @api_docs_service
      preview_admin_api_docs_service_path(spec)
    when /(?:the spec's|spec "(.*)") edit page from Audience context/
      spec = $1.present? ? @provider.api_docs_services.find_by!(name: $1) : @api_docs_service
      edit_admin_api_docs_service_path(spec)

    when /the product's ActiveDocs page/
      admin_service_api_docs_path(@product)
    when /the product's new ActiveDocs spec page/
      new_admin_service_api_doc_path(@product)
    when /(?:the spec's|spec "(.*)") preview page from Product context/
      spec = $1.present? ? @provider.api_docs_services.find_by!(name: $1) : @api_docs_service
      preview_admin_service_api_doc_path(spec.service, spec)
    when /(?:the spec's|spec "(.*)") edit page from Product context/
      spec = $1.present? ? @provider.api_docs_services.find_by!(name: $1) : @api_docs_service
      edit_admin_service_api_doc_path(service_id: spec.service, id: spec)

    #
    # API Management
    #
    when /(the )?API dashboard( page)?/
      admin_service_path provider_first_service!
    when /^the overview page of product "([^"]+)"$/
      admin_service_path @provider.services.find_by!(name: $1)

    when 'the alerts page'
      admin_alerts_path

    when /^the alerts of "(.*)"$/
      admin_service_alerts_path(Service.find_by!(name: $1))

    when /^the (edit|settings) page for service "([^"]+)" of provider "(.+?)"$/
      provider = Account.providers.find_by_org_name! $3
      service = provider.services.find_by_name! $2
      polymorphic_path [$1.to_sym, :admin, service]

    when 'the new service page'
      new_admin_service_path

    when 'the service plans admin page'
      admin_service_service_plans_path provider_first_service!

    when /^the usage rules of service "([^"]*)"$/
      service = Service.find_by!(name: Regexp.last_match(1))
      usage_rules_admin_service_path(service)

    when /^the backends of the product$/
      admin_service_backend_usages_path(Service.last)

    when /^the backends of product "(.+?)"$/
      product = Service.find_by!(name: $1)
      admin_service_backend_usages_path(product)

    when /^the new backend page for product "(.*)"$/
      product = Service.find_by!(name: $1)
      new_admin_service_backend_usage_path(product)

    when /^the edit backend usage page of "(.*)" for product "(.*)"$/
      product = Service.find_by!(name: $2)
      config = product.backend_api_configs
                      .references(:backend_api)
                      .includes(:backend_api)
                      .find_by!("backend_apis.name" => $1)
      edit_admin_service_backend_usage_path(product, config)

    when /^the integration errors page of product "([^"]+)"$/
      service = Service.find_by!(name: $1)
      admin_service_errors_path(service)

    #
    # Plans (Admin portal)
    #
    when /^(?:(application|service|account) )?plan "(.*)" admin edit page$/
      model = case $1
              when 'application' then ApplicationPlan
              when 'service' then ServicePlan
              when 'account' then AccountPlan
              else Plan
              end

      plan = model.find_by!(name: $2)
      edit_polymorphic_path([:admin, plan])

    #
    # Application plans (Admin portal)
    #
    when /^(product "(.*)"|the product's) application plans admin page$/
      product = Service.find_by(name: $2) || @product || @service || provider_first_service!
      admin_service_application_plans_path(product)

    when /^(product "(.*)"|the product's) new application plan admin page$/
      product = Service.find_by(name: $2) || @product || @service || provider_first_service!
      new_admin_service_application_plan_path(product)

    #
    # Service plans (Admin portal)
    #
    when /^(product "(.*)"|the product's) service plans admin page$/
      product = Service.find_by(name: $2) || @product || @service || provider_first_service!
      admin_service_service_plans_path(product)

    when /^(product "(.*)"|the product's) new service plan admin page$/
      product = Service.find_by(name: $2) || @product || @service || provider_first_service!
      new_admin_service_service_plan_path(product)

    #
    # Account plans (Admin portal)
    #
    when 'the account plans admin page'
      admin_buyers_account_plans_path

    when 'the new account plan admin page'
      # FIXME: this should be new_admin_buyers_account_plan_path
      new_admin_account_plan_path

    #
    # Service contracts (Admin portal)
    #
    when 'the service subscription page'
      new_admin_service_contract_path

    when 'the provider service subscriptions page'
      admin_buyers_service_contracts_path

    when /^(?:buyer "(.*)"|the buyer's) service subscriptions page$/
      buyer = $1.present? ? Account.buyers.find_by!(org_name: $1) : @buyer
      admin_buyers_account_service_contracts_path(buyer)

    #
    # Applications (Admin portal)
    #
    when /^(buyer|product|the admin portal)( "(.*)")? applications page(?: with (\d+) records? per page)?$/
      case $1
      when 'buyer'
        admin_buyers_account_applications_path(Account.buyers.find_by!(org_name: $3), per_page: $4)
      when 'product'
        admin_service_applications_path(Service.find_by!(name: $3), per_page: $4)
      when 'the admin portal'
        provider_admin_applications_path(per_page: $4)
      end

    when /^(buyer|product|the admin portal)( "(.*)")? new application page$/
      case $1
      when 'buyer'
        new_admin_buyers_account_application_path(Account.buyers.find_by!(org_name: $3))
      when 'product'
        new_admin_service_application_path(Service.find_by!(name: $3))
      when "the admin portal"
        new_provider_admin_application_path
      end

    when /^(application "(.*)"|the application's) admin page$/
      app_name = $2
      app = app_name.present? ? Cinstance.find_by(name: app_name) : (@cinstance || @application)
      provider_admin_application_path(app)

    when /^(application "(.*)"|the application's) admin edit page$/
      app_name = $2
      app = app_name.present? ? Cinstance.find_by(name: app_name) : (@cinstance || @application)
      edit_provider_admin_application_path(app)

    when 'the admin portal data exports page'
      new_provider_admin_account_data_exports_path

    when 'the upgrade notice for multiple applications'
      admin_upgrade_notice_path(:multiple_applications)

    when /^(application "(.*)"|the application's) traffic stats page$/
      app = Cinstance.find_by(name: $2) || @cinstance || @application
      admin_buyers_stats_application_path(app)

    #
    # Applications (Developer portal)
    #
    when 'the dev portal applications page'
      admin_applications_path

    when 'the service selection page'
      choose_service_admin_applications_path

    when 'the dev portal API access details page'
      admin_applications_access_details_path

    when /^(?:application "(.*)"|the application's) dev portal page$/
      app = Cinstance.find_by(name: $1) || @cinstance || @application
      admin_application_path(app)

    when /^(?:application "(.*)"|the application's) dev portal edit page$/
      app = Cinstance.find_by(name: $1) || @cinstance || @application
      edit_admin_application_path(app)

    when 'the dev portal new application page'
      new_admin_application_path

    when /^(?:product "(.*)"|the product's) dev portal new application page$/
      service = Service.find_by(name: $1) || @product || @service
      new_admin_application_path(service_id: service.system_name)

    when /^the alerts page of application "(.+?)"$/
      cinstance = Cinstance.find_by_name!($1)
      admin_application_alerts_path(cinstance)


    #
    # Developer portal
    #
    when "the account plans page"
      admin_account_account_plans_path

    when /the services list for buyers( page)?$/
      admin_buyer_services_path

    #
    # Buyer management
    #
    when 'the buyer accounts page', 'the accounts admin page',
         /^the buyer accounts page with (\d+) records? per page$/
      admin_buyers_accounts_path(:per_page => $1)
    when /^the ([^ ]*) buyer accounts page$/
      admin_buyers_accounts_path(:state => $1)
    when 'the new buyer account page'
      new_admin_buyers_account_path

    when /^the buyer account page for "([^"]*)"$/,
         /^the buyer account "([^"]*)" page$/,
         /^buyer "(.*)" overview page$/,
         /^the overview page of account "([^"]*)"$/
      admin_buyers_account_path(Account.find_by!(org_name: $1))

    when /^the buyer account edit page for "([^"]*)"$/,
         /^the buyer account "([^"]*)" edit page$/
      edit_admin_buyers_account_path(Account.find_by_org_name!($1))

    when /^the buyer users page for "([^"]*)"$/,
         /^the buyer account "([^"]*)" users page$/
      admin_buyers_account_users_path(Account.find_by_org_name!($1))

    when /^the buyer user page for "([^"]*)"$/,
         /^the buyer user "([^"]*)" page$/
      user = User.find_by_username!($1)
      admin_buyers_account_user_path(user.account, user)

    when /^the buyer user edit page for "([^"]*)"$/,
         /^the buyer user "([^"]*)" edit page$/
      user = User.find_by_username!($1)
      edit_admin_buyers_account_user_path(user.account, user)

    when /^the buyer account "([^"]*)" invitations page$/
      admin_buyers_account_invitations_path(Account.find_by_org_name!($1))
    when /^the buyer account "([^"]*)" new invitation page$/
      new_admin_buyers_account_invitation_path(Account.find_by_org_name!($1))

    when /^the buyer account "([^"]*)" groups page$/
      admin_buyers_account_groups_path(Account.find_by_org_name!($1))

    when /^the data exports page$/
      new_admin_data_exports_path

    #
    # Forum admin
    #
    when 'the admin portal forum page'
      admin_forum_path
    when 'the admin portal new topic page'
      new_admin_forum_topic_path
    when /^the admin portal "([^"]*)" topic page$/
      admin_forum_topic_path(Topic.find_by_title!($1))
    when /^the admin portal edit "([^"]*)" topic page$/
      edit_admin_forum_topic_path(Topic.find_by_title!($1))
    when 'the admin portal forum categories page'
      admin_forum_categories_path
    when 'the admin portal new forum category page'
      new_admin_forum_category_path

    #
    # Site settings
    #
    when 'the edit site settings page',
         'the site settings page'
      edit_admin_site_settings_path

    when 'the usage rules settings page'
      edit_admin_site_usage_rules_path

    when /^the "([^"]*)" destroys page$/
      provider_admin_destroys_path(:kind => $1)

    when 'the dns settings page'
      admin_site_dns_path

    when 'the bot protection page'
      edit_admin_site_spam_protection_path

    when 'the xss protection page'
      edit_admin_site_developer_portal_path

    when 'the feature visibility page'
      provider_admin_cms_switches_path

    when 'the fields definitions index page'
      admin_fields_definitions_path

    when 'the settings page'
     admin_apiconfig_root_path

    when 'the documentation settings page'
      edit_admin_site_documentation_path

    when 'the emails settings page'
      edit_admin_site_emails_path

    #
    # Stats
    #
    # FIXME: this feels really wrong, passing default service
    when 'the provider stats usage page'
      admin_service_stats_usage_path provider_first_service!
    when 'the provider stats apps page'
      admin_service_stats_top_applications_path provider_first_service!
    when 'the provider stats days page'
      admin_service_stats_days_path provider_first_service!
    when 'the provider stats hours page'
      admin_service_stats_hours_path provider_first_service!
    when 'the buyer stats page'
      buyer_stats_path
    when 'the buyer stats usage page'
      usage_stats_api_applications_path provider_first_service!.cinstances.first, *args

    #
    # Potato CMS
    when 'the CMS new partial page'
      new_provider_admin_cms_partial_path

    when 'the CMS new redirect page'
      new_provider_admin_cms_redirect_path

    when 'the CMS new layout page'
      new_provider_admin_cms_layout_path

    when /^the new CMS groups page$/
      new_provider_admin_cms_group_path

    when /^the email templates page$/
      provider_admin_cms_email_templates_path

    when /^the legal terms settings page$/
      # see CMS::Builtin::LegalTerm for the system names
      new_provider_admin_cms_builtin_legal_term_path(system_name: 'signup_licence')

    when /^the groups page$/
      provider_admin_cms_groups_path

    when /^the CMS Page "(.+?)" page$/i
      page = CMS::Page.find_by_path!($1)
      edit_provider_admin_cms_page_path(page)

    when 'the CMS changes'
      provider_admin_cms_changes_path

    ## DELETE THESE & FIX CUKES
    when /^the CMS Sections page$/
      provider_admin_cms_sections_path
    when /^the CMS Files page$/
      provider_admin_cms_files_path

    #
    # Advanced CMS (BrowserCMS)
    #
    when 'the CMS content library page',
         'the portal area page',
         /^the CMS Templates page$/,
         /^the (?:CMS|cms) page$/
      provider_admin_cms_templates_path

    when /^the edit page of the html block "([^"]*)"$/
      html_block = HtmlBlock.find_by_name($1)
      edit_cms_html_block_path html_block
    #
    # Buyer
    #
    when 'the buyer payment details page'
      "/buyer/payment_details"

    when 'the buyer access details page'
      buyer_access_details_path

    #
    # Finance (Admin portal)
    #
    when 'the earnings by month page'
      admin_finance_root_path

    when 'the finance settings page'
      admin_finance_settings_path

    when /^(?:the invoice|invoice "(.*)") admin portal page$/
      invoice = if $1.present?
                  Invoice.find_by!(friendly_id: $1)
                else
                  @invoice
                end
      admin_finance_invoice_path(invoice)

    when /^the invoices page of account "(.+?)"$/,
        /^buyer "(.*)" invoices page$/
      account = Account.find_by!(org_name: $1)
      admin_buyers_account_invoices_path(account)

    when /^the admin portal invoices page$/
      admin_finance_invoices_path

    when 'the log entries page'
      admin_finance_log_entries_path

    when 'the 3scale invoices page'
      provider_admin_account_invoices_path

    when /^the 3scale invoice for "(\w+, \d{4})"$/
      # WATCH OUT: different accounts could have different invoices for the same period.
      invoice = Invoice.find { |i| i.name == $1 }
      provider_admin_account_invoice_path(invoice)

    #
    # Finance (Developer portal)
    #
    when 'the dev portal invoices page'
      admin_account_invoices_path

    when /^the invoice "(.*)" dev portal page$/
      invoice = Invoice.find_by!(friendly_id: $1)
      admin_account_invoice_path(invoice)

    when 'the provider site page'
      admin_site_settings_path

    when 'the new webhook page'
      new_provider_admin_webhooks_path

    when 'the edit webhooks page'
      edit_provider_admin_webhooks_path

    #Previous routes still used.
    when 'the provider access rules page'
      '/admin/settings/accessrules'

    when 'the terms of service page'
      '/termsofservice'
    when 'the privacy policy page'
      '/privacypolicy'
    when 'the refund policy page'
      '/refundpolicy'

    # Methods and metrics
    when 'the metrics and methods page'
      admin_service_metrics_path(@provider.default_service)
    when 'the metrics and methods page of my backend api'
      provider_admin_backend_api_metrics_path(@provider.default_service.backend_api)
    when /^the (methods|metrics) page of product "(.+?)"/
      admin_service_metrics_path(Service.find_by!(name: $2), tab: $1)
    when /^the new metric page of product "(.+?)"/
      new_admin_service_metric_path Service.find_by!(name: $1)
    when /^the new method page of product "(.+?)"/
      service = Service.find_by!(name: $1)
      new_admin_service_metric_child_path(service, service.metrics.hits)
    when /^the edit page of (?:metric|method) "(.+?)"/
      metric = Metric.find_by!(friendly_name: $1)
      edit_admin_service_metric_path(metric.owner, metric)

    # Proxy
    when /^the integration show page for service "(.+?)"/
      service = Service.find_by!(name: $1)
      admin_service_integration_path(service)
    when /^the mapping rules index page for service "(.+?)"/
      service = Service.find_by!(name: $1)
      admin_service_proxy_rules_path(service)
    when /^the mapping rules index page for backend "(.+?)"/
      provider_admin_backend_api_mapping_rules_path(BackendApi.find_by!(name: $1))
    when /^the create mapping rule page for service "(.+?)"/
      service = Service.find_by!(name: $1)
      new_admin_service_proxy_rule_path(service)
    when /^the create mapping rule page for backend "(.+?)"/
      new_provider_admin_backend_api_mapping_rule_path(BackendApi.find_by!(name: $1))
    when /^the integration page for service "(.+?)"/
      # TODO: THREESCALE-3759 edit page no longer exist, remove or replace
      service = Service.find_by!(name: $1)
      edit_admin_service_integration_path(service)

    when 'the 404 page'
      '/the-404-page'

    # Backend API
    when /^the admin portal new backend api page/
      new_provider_admin_backend_api_path
    when /^the admin portal overview page of backend "(.*)"/
      provider_admin_backend_api_path(BackendApi.find_by!(name: $1))
    when /^the backend api overview/
      provider_admin_backend_api_path(provider_first_service!.backend_api)

    #
    # Help
    #
    when /^the liquid reference$/
      provider_admin_liquid_docs_path

    #
    # Upgrade notices
    #
    when /^the upgrade notice page for "(.+?)"$/
      admin_upgrade_notice_path($1)

    #
    # Quick starts
    #
    when /^the quick start catalog page$/
      provider_admin_quickstarts_path

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end)
# rubocop:enable Style/PerlBackrefs
