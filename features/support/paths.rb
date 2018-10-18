# frozen_string_literal: true

World(Module.new do
  break unless defined?(DeveloperPortal)

  include DeveloperPortal::Engine.routes.url_helpers

  def provider_first_service!
    @provider.first_service!
  end

  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name, *args)
    case page_name

    # Public
    when /the home\s?page/
      '/'

    when 'the authentication providers page'
      provider_admin_authentication_providers_path

    when /^the sign up page for the "([^"]*)" plan$/
      plan = Plan.find_by_name!($1)
      signup_path(:'plan_ids[]' => plan.id)

    when /the sign ?up page/, 'the old multiapps sign up page'
      signup_path

    when 'the provider sign up page'
      provider_signup_path

    when 'the provider login page'
      provider_login_path

    when 'the provider onboarding wizard page'
      provider_admin_onboarding_wizard_intro_path

    when 'the login page'
      login_path

    when 'the signup page'
      signup_path

    when /^the login page on ([a-z0-9\.\-]+)$/
      login_url(:host => $1)

    when 'logout'
      logout_path

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
    # Messages - provider side
    #

    when "the provider inbox page"
      provider_admin_messages_root_path

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
    when "forum settings"
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

    when 'search'
      search_path
    when 'the search page'
      search_path
    #
    # Account management
    #
    when 'the account page'
      admin_account_path

    when 'the account edit page'
      edit_admin_account_path

    when 'the provider account page'
      provider_admin_account_path

    when 'the provider personal page'
      edit_provider_admin_user_personal_details_path

    when 'the provider edit account page',
         'the provider account edit page'
      edit_provider_admin_account_path

    when 'the edit credit card details page'
      edit_admin_account_braintree_blue_path
    when 'the credit card details page'
      admin_account_payment_details_path
    when 'the provider braintree credit card details page'
      provider_admin_account_braintree_blue_path
    when 'the provider braintree edit credit card details page'
      edit_provider_admin_account_braintree_blue_path

    when 'the braintree credit card details page'
      admin_account_braintree_blue_path
    when 'the braintree edit credit card details page'
      edit_admin_account_braintree_blue_path
    when 'the ogone credit card details page'
      admin_account_ogone_path
    when 'the ogone edit credit card details page'
      edit_admin_account_ogone_path
    when 'the stripe credit card details page'
      admin_account_stripe_path
    when 'the stripe edit credit card details page'
      edit_admin_account_stripe_path
    when 'the provider personal details page'
      edit_provider_admin_user_personal_details_path
    when 'the personal details page'
      admin_account_personal_details_path
    when 'the notifications page'
      provider_admin_account_notifications_path
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
    when /^the provider user edit page for "([^"]*)"$/
      user = User.find_by_username!($1)
      edit_provider_admin_account_user_path(user)
    when 'the new invitation page'
      new_admin_account_invitation_path
    when 'the sent invitations page'
      admin_account_invitations_path
    when 'the account signup page with invalid invitation token'
      invitee_signup_path(:invitation_token => 'invalid')
    when 'the provider user signup page with invalid invitation token'
      provider_invitee_signup_path(:invitation_token => 'invalid')
    when 'the provider new invitation page'
      new_provider_admin_account_invitation_path
    when 'the provider sent invitations page'
      provider_admin_account_invitations_path
    when 'the edit provider logo page'
      edit_provider_admin_account_logo_path

    #
    # API Management
    #
    when 'the new active docs page'
      new_admin_api_docs_service_path
    when 'the provider active docs page'
      admin_api_docs_services_path
    when /the "([^"]*)" active docs raw page/
      active_doc = ApiDocs::Service.find_by_system_name $1
      admin_api_docs_service_path active_doc.system_name, format: :json

    when /(the )?API dashboard( page)?/
      admin_service_path provider_first_service!

    when 'the API alerts page'
      admin_alerts_path

    when /^the API alerts page of service "(.+?)" of provider "(.+?)"$/
      provider = Account.providers.find_by_org_name! $2
      service = provider.services.find_by_name! $1
      admin_service_alerts_path(service)

    when /^the (edit|settings) page for service "([^"]+)" of provider "(.+?)"$/
      provider = Account.providers.find_by_org_name! $3
      service = provider.services.find_by_name! $2
      polymorphic_path [$1, :admin, service]

    when 'the new service page'
      new_admin_service_path

    when /^the edit page for end user plan "(.+?)"$/
      plan = EndUserPlan.find_by_name! $1
      edit_admin_end_user_plan_path(plan)

    when /^the end user plans of service "(.+?)" page of provider "(.+?)"$/
      #OPTIMIZE: instead of doing 'of provider "..."' it is better to keep provider_account
      # in @current_account in a session/login step
      provider = Account.providers.find_by_org_name! $2
      service = provider.services.find_by_name! $1
      admin_service_end_user_plans_path(service)

    when /^the end users of service "(.+?)" page of provider "(.+?)"$/
      #OPTIMIZE: instead of doing 'of provider "..."' it is better to keep provider_account
      # in @current_account in a session/login step
      provider = Account.providers.find_by_org_name! $2
      service = provider.services.find_by_name! $1
      admin_service_end_users_path(service)

    when /^the end user "(.+?)" of service "(.+?)" page of provider "(.+?)"$/
      #OPTIMIZE: instead of doing 'of provider "..."' it is better to keep provider_account
      # in @current_account in a session/login step
      provider = Account.providers.find_by_org_name! $3
      service = provider.services.find_by_name! $2
      admin_service_end_user_path(service, $1)

    when 'the account plans admin page'
      admin_buyers_account_plans_path

    when 'the new account plan page'
      new_admin_buyers_account_plan_path

    when 'the application plans admin page'
      admin_service_application_plans_path provider_first_service!

    when 'the default application plan admin page'
      edit_polymorphic_path([:admin, provider_first_service!.application_plans.first])

    when 'the service plans admin page'
      admin_service_service_plans_path provider_first_service!

    when /^the edit page for plan "([^"]*)"$/, /^the edit for plan "([^"]*)" page$/
      plan = Plan.find_by_name!($1)
      edit_polymorphic_path([:admin, plan])

    when 'the latest transactions page'
      admin_transactions_path


    #
    # Account plans (buyer side)
    #
    when "the account plans page"
      admin_account_account_plans_path

    #
    # Applications (buyer side)
    #
    when 'the applications page'
      admin_applications_path
    when 'the new application page'
      new_admin_application_path
    when /^the new application page for service "([^"]*)"$/
      service = Service.find_by_name!($1)
      new_admin_application_path(:service_id => service.id)

    when /^my application page$/
      admin_application_path(@application)
    when /^the "([^"]*)" application page$/
      cinstance = Cinstance.find_by_name!($1)
      admin_application_path(cinstance)
    when /^the "([^"]*)" application edit page$/
      cinstance = Cinstance.find_by_name!($1)
      edit_admin_application_path(cinstance)
    when 'the API access details page'
      admin_applications_access_details_path

    when /^the alerts page of application "(.+?)"$/
      cinstance = Cinstance.find_by_name!($1)
      admin_application_alerts_path(cinstance)

    #
    # Service contracts (subscriptions)
    #
    when 'the service subscription page'
      new_admin_service_contract_path

    when /the services list for buyers( page)?$/
      admin_buyer_services_path

    when 'the service subscriptions list for provider',
         'the subscriptions admin page',
         /^the subscriptions admin page with (\d+) records? per page$/
      admin_buyers_service_contracts_path(:per_page => $1)

    #
    # Applications (provider side)
    #
    when /^the provider side create application page for "([^"]*)"$/
      buyer = Account.buyers.find_by_org_name($1)
      new_admin_buyers_account_application_path(buyer)

    when /^the provider side "([^"]*)" application page$/
      application = Cinstance.find_by_name!($1)
      admin_service_application_path(application.service, application)

    when /^the provider side "([^"]*)" edit application page$/
      application = Cinstance.find_by_name!($1)
      edit_admin_service_application_path(application.service, application)

    when /^the provider side application page for "([^"]*)"$/
      application = Account.find_by_org_name!($1).bought_cinstance
      admin_service_application_path(application.service, application)

    when 'the applications admin page',
         /^the applications admin page with (\d+) records? per page$/
      admin_buyers_applications_path(:per_page => $1)

    when /^the provider side edit page for application "([^"]*)" of buyer "([^"]*)"$/
      application = Account.find_by_org_name!($2).bought_cinstances.find_by_name!($1)
      edit_admin_service_application_path(application.service, application)

    #
    # Service contracts (provider side)
    #
    when 'the service contracts admin page'
      admin_buyers_service_contracts_path


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

    when /^the buyer account page for "([^"]*)"$/
      admin_buyers_account_path(Account.find_by_org_name!($1))
    when /^the buyer account "([^"]*)" page$/
      admin_buyers_account_path(Account.find_by_org_name!($1))

    when /^the buyer account edit page for "([^"]*)"$/
      edit_admin_buyers_account_path(Account.find_by_org_name!($1))
    when /^the buyer account "([^"]*)" edit page$/
      edit_admin_buyers_account_path(Account.find_by_org_name!($1))

    when /^the buyer users page for "([^"]*)"$/
      admin_buyers_account_users_path(Account.find_by_org_name!($1))
    when /^the buyer account "([^"]*)" users page$/
      admin_buyers_account_users_path(Account.find_by_org_name!($1))

    when /^the buyer user page for "([^"]*)"$/
      user = User.find_by_username!($1)
      admin_buyers_account_user_path(user.account, user)
    when /^the buyer user "([^"]*)" page$/
      user = User.find_by_username!($1)
      admin_buyers_account_user_path(user.account, user)

    when /^the buyer user edit page for "([^"]*)"$/
      user = User.find_by_username!($1)
      edit_admin_buyers_account_user_path(user.account, user)
    when /^the buyer user "([^"]*)" edit page$/
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

    when /^the buyer account config page for "([^"]*)"$/
      admin_buyers_account_configs_path(Account.find_by_org_name!($1))

    when /^the buyer account service contracts page for "([^"]*)"$/
      admin_buyers_account_service_contracts_path Account.find_by_org_name!($1)


    #
    # Forum admin
    #
    when 'the provider side forum page'
      admin_forum_path
    when 'the provider side new topic page'
      new_admin_forum_topic_path
    when /^the provider side "([^"]*)" topic page$/
      admin_forum_topic_path(Topic.find_by_title!($1))
    when /^the provider side edit "([^"]*)" topic page$/
      edit_admin_forum_topic_path(Topic.find_by_title!($1))
    when 'the provider side forum categories page'
      admin_forum_categories_path
    when 'the provider side new forum category page'
      new_admin_forum_category_path

    #
    # Site settings
    #
    when 'the edit site settings page'
      edit_admin_site_settings_path

    when 'the site settings page'
      edit_admin_site_settings_path

    when 'the usage rules settings page'
      edit_admin_site_usage_rules_path

    when /^the "([^"]*)" destroys page$/
      provider_admin_destroys_path(:kind => $1)

    when 'the dns settings page'
      admin_site_dns_path

    when 'the spam protection page'
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

    when 'the forum settings page'
      edit_admin_site_forum_path

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
      usage_stats_data_applications_path provider_first_service!.cinstances.first, *args
    #
    # Potato CMS
    when /^the (?:CMS|cms) page$/
      provider_admin_cms_templates_path

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
    when /^the CMS Templates page$/
      provider_admin_cms_templates_path
    when /^the CMS Sections page$/
      provider_admin_cms_sections_path
    when /^the CMS Files page$/
      provider_admin_cms_files_path


    #
    # Simple CMS
    #
    when 'the CMS page templates page'
      admin_cms_page_templates_path

    #
    # Advanced CMS (BrowserCMS)
    #
    when 'the CMS content library page', 'the portal area page'
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

    when 'the buyer dashboard'
      '/'

    # Provider - Finance
    when 'the finance page', 'the invoices by months page'
      admin_finance_root_path

    when "finance settings"
      admin_finance_settings_path

    when /(the )?finance settings( page)?/
      admin_finance_settings_path

    when 'my invoices'
      admin_account_invoices_path

    when /^the invoices of (account ".+?") page$/
      account = Transform $1
      admin_buyers_account_invoices_path(account)

    when /^the invoices issued by me$/
      admin_finance_invoices_path

    when /^the (invoice ".+?") page$/
      invoice = Transform $1
      admin_finance_account_invoice_path(invoice.buyer_account, invoice)

    when /^the invoices page$/
      admin_account_invoices_path

    when 'the credit card gateway page'
      admin_account_payment_gateway_path

    when 'my invoices from 3scale page'
      provider_admin_account_invoices_path

    when 'the log entries page'
      admin_finance_log_entries_path

    when 'the provider site page'
      admin_site_settings_path

    when 'the latest transactions page'
      admin_transactions_path

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

    # Proxy
    when 'the service definition page'
      admin_service_metrics_path(provider_first_service!)
    when /^the integration show page for (service ".+?")/
      admin_service_integration_path(Transform $1)
    when /^the integration page for (service ".+?")/
      edit_admin_service_integration_path(Transform $1)
    when 'the service integration page'
      edit_admin_service_integration_path(provider_first_service!)

    when 'the 404 page'
      '/the-404-page'

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
