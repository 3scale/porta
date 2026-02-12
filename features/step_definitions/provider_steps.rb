# frozen_string_literal: true

def import_simple_layout(provider)
  simple_layout = SimpleLayout.new(provider)
  simple_layout.import_pages!
  simple_layout.import_js_and_css! if javascript_test?
end

Given "a provider signed up to {plan}" do |plan|
  create_provider_with_plan('foo.3scale.localhost', plan)
end

Given "a provider {string} signed up to {plan}" do |name, plan|
  create_provider_with_plan(name, plan)
end

Given "a(nother) provider {string}" do |account_name|
  create_provider_with_plan(account_name, ApplicationPlan.first)
end

Given(/^a provider "([^"]*)" with default plans$/) do |name|
  create_provider_with_plan(name, ApplicationPlan.first)

  product = @provider.first_service!
  FactoryBot.create(:account_plan, name: 'default_account_plan', issuer: @provider, default: true)
  FactoryBot.create(:service_plan, name: 'default_service_plan', issuer: product, default: true)
  FactoryBot.create(:application_plan, name: 'default_application_plan', issuer: product, default: true)
end

Given(/^the current provider is (.+?)$/) do |name|
  @provider = Account.providers.find_by_org_name!(name)
end

Given(/^a provider "(.*?)" with impersonation_admin admin$/) do |provider_name|
  create_provider_with_plan(provider_name, ApplicationPlan.first)
  provider = @provider
  if provider.admins.impersonation_admins.empty?
    FactoryBot.create :active_admin, username: ThreeScale.config.impersonation_admin[:username], account: provider
  end
end

Given(/^there is no provider with domain "([^"]*)"$/) do |domain|
  Account.find_by_domain(domain).try!(&:destroy)
end

Given "{provider} has the following fields defined for {field_definition_target}:" do |provider, target, table|
  provider.fields_definitions.by_target(target).each(&:destroy)

  parameterize_headers(table)
  table.hashes.each do |hash|
    hash.delete_if { |k, v| v.blank? }

    hash['choices'] = hash['choices'].split( /\s*,\s*/ ) if hash['choices'].is_a?(String)

    label = hash[:label] || hash.fetch('name').humanize
    name = hash[:name] || hash.fetch('label').parameterize.underscore

    provider.fields_definitions.create!(hash.merge!(target: target, label: label, name: name))
  end
end

Given "{provider} has the field {string} for {string} in the position {int}" do |provider, name, klass, pos|
  a = provider.fields_definitions.by_target(klass.underscore).find{ |fd| fd.name == name }
  a.pos = pos
  a.save!
end

Given "{provider} has the field {string} for {field_definition_target} as {read_only_status}" do |provider, name, target, read_only|
  a = provider.fields_definitions.by_target(target).find { |fd| fd.name == name }
  a.read_only = read_only
  a.save!
end

Given "{provider} allows to change account plan {change_plan_permission}" do |provider, plan_permission|
  provider.set_change_account_plan_permission! plan_permission
end

Given "{provider} does not allow to change account plan" do |provider|
  provider.set_change_account_plan_permission!(:none)
end

Given "{product} allows to change application plan {change_plan_permission}" do |product, plan_permission|
  product.set_change_application_plan_permission! plan_permission
end

Given "{provider} service allows to change application plan {change_plan_permission}" do |provider, plan_permission|
  provider.default_service.set_change_application_plan_permission! plan_permission
end

Given "{provider} allows to change service plan {change_plan_permission}" do |provider, plan_permission|
  provider.set_change_service_plan_permission! plan_permission
end

Given "{provider} has no published application plans" do |provider|
  provider.application_plans.published.each(&:hide!)
  # provider.application_plans.each(&:hide!)
end

Given "{provider} has all the templates setup" do |provider|
  provider.files.delete_all
  provider.templates.delete_all

  SimpleLayout.new(provider).import!
end

Given "{provider} has opt-out for credit card workflow on plan changes" do |provider|
  search = '{% plan_widget application, wizard: true %}'
  replacement = '{% plan_widget application, wizard: false %}'
  partial = @provider.builtin_partials.find_by!(system_name: 'applications/form')
  draft = partial.published.dup
  assert draft.gsub!(search, replacement), 'failed to enable the wizard'
  partial.draft = draft
  partial.publish!

  page = @provider.builtin_pages.find_by!(system_name: 'applications/show')
  draft = page.published.dup
  assert draft.gsub!(search, replacement), 'failed to enable the wizard'
  page.draft = draft
  page.publish!
end

Given "{provider} requires cinstances to be approved before use" do |provider|
  provider.application_plans.each do |plan|
    plan.approval_required = true
    plan.save!
  end
end

Given "{provider} has no account plans" do |provider|
  provider.account_plans.delete_all
end

Given "{provider} has an sso integration for the admin portal" do |provider|
  @authentication_provider = FactoryBot.create(:self_authentication_provider, account: provider)
end

Given "{provider} has sso {enabled} for all users" do |provider, enabled|
  provider.settings.update_column(:enforce_sso, enabled)
end

And /^the sso integration is (published|hidden)$/ do |state|
  @authentication_provider.update!(published: state == 'published')
end

And /^the sso integration is tested$/ do
  EnforceSSOValidator.any_instance.stubs(:valid?).returns(true)
end

When "{provider} creates sample data" do |provider|
  provider.create_sample_data!
end

Given(/^a provider signs up and activates his account$/) do
  set_current_domain Account.master.external_admin_domain
  visit provider_signup_path

  user = FactoryBot.build_stubbed(:user)

  within signup_form do
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'superSecret1234#'

    fill_in 'Organization/Group Name', with: 'provider'
    fill_in 'Developer Portal', with: 'foo'

    click_on 'Sign up'
  end

  page.should have_content('Thank you for signing up.')

  set_current_domain Account.find_by(org_name: 'provider').external_admin_domain

  email = open_email(user.email, with_subject: 'Account Activation')
  click_first_link_in_email(email)

  stub_integration_errors_dashboard

  within login_form do
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'superSecret1234#'

    click_on 'Sign in'
  end

  assert_content 'Hello admin,'

  @provider = Account.find_by_self_domain!(@domain)
end

Then(/^the provider should not have any notifications$/) do
  notifications = Notification.where(user_id: @provider.users)

  assert_equal 0, notifications.count
end

def signup_form
  find('#signup_form')
end

def login_form
  find('#new_session')
end

Given('a provider exists') do
  create_provider_with_plan('foo.3scale.localhost', ApplicationPlan.first)
  @service ||= @provider.default_service
end

Given('Provider has setup RH SSO') do
  create_provider_with_plan('foo.3scale.localhost', ApplicationPlan.first)
  @provider.settings.deny_multiple_applications! if @provider.settings.can_deny_multiple_applications?

  service = @provider.first_service!
  service.publish!
  @provider.update_attribute(:default_account_plan, @provider.account_plans.first)

  plans = service.service_plans
  plans.default!(plans.default_or_first || plans.first)

  FactoryBot.create(:application_plan, name: 'Base',
                                       issuer: @provider.first_service!,
                                       default: true)
  provider_publish_auth_provider "Keycloak"
  set_current_domain @provider.external_domain
end

And('As a developer, I see RH-SSO login option on the login page') do
  visit login_path
  has_link?("Authenticate with #{@authentication_provider.name}", href: %r{auth/realms/3scale/protocol/openid-connect/auth\?client_id=.*redirect_uri=.*response_type=code&scope=.*})
end

Given(/^a provider( is logged in)?$/) do |login|
  setup_provider(login)
end

Given(/^a provider( is logged in)? with a product "([^"]*)"$/) do |login, name|
  setup_provider(login)
  @service = @provider.services.create!(name: name, mandatory_app_key: false)
end

# Set up a provider with specific data. Example:
#
# Given a provider with:
#   | org_name      | Bananas          |
#   | support_email | support@api.test |
#
Given "a provider with:" do |table|
  setup_provider(false)

  parameterize_headers(table)
  @provider.update! table.rows_hash
end

def setup_provider(login)
  create_provider_with_plan("foo.3scale.localhost", ApplicationPlan.first)
  set_current_domain(@provider.external_admin_domain)
  stub_integration_errors_dashboard

  return unless login

  try_provider_login('foo.3scale.localhost', 'superSecret1234#')
  assert user_is_logged_in('foo.3scale.localhost')
end

Given "{provider} has {} set to {string}" do |provider, name, value|
  provider.update_attribute(underscore_spaces(name), value) # rubocop:disable Rails/SkipsModelValidations
end

Then "{provider}'s {} should (still )be {string}" do |provider, name, value|
  assert_equal value, provider.send(underscore_spaces(name))
end

def create_provider_with_plan(name, plan) # TODO: RENAME THIS NOWWW
  @provider = FactoryBot.create(:provider_account_with_pending_users_signed_up_to_no_plan, org_name: name,
                                                                                           domain: name,
                                                                                           self_domain: "admin.#{name}")
  unless @provider.bought?(plan)
    @provider.application_contracts.delete_all
    @provider.buy!(plan, name: 'Default', description: 'Default')
    @provider.bought_cinstances.reset
  end

  import_simple_layout(@provider)
end

Given(/^master admin( is logged in)?/) do |login|
  @master = @provider = Account.master
  admin = @provider.admins.first!
  set_current_domain @master.external_domain
  stub_integration_errors_dashboard
  if login
    try_provider_login(admin.username, 'superSecret1234#')
    assert user_is_logged_in(admin.username)
  end
end

When(/^I have opened edit page for the active member$/) do
  visit provider_admin_account_users_path
  user = User.find_by!(username: 'alex')
  find("tr#user_#{user.id} .pf-c-table__action").click_link('Edit')
  assert_text 'Edit User'
end

Then(/^no permissions should be checked$/) do
  within('.FeatureAccessList') do
    all('input[type=checkbox]').each do |input|
      refute(input.checked?) if input.value.present?
    end
  end
end

Given(/^the provider account allows signups$/) do
  @provider.settings.deny_multiple_applications! if @provider.settings.can_deny_multiple_applications?
  service = @provider.first_service!
  service.publish!
  @provider.update_attribute(:default_account_plan, @provider.account_plans.first)

  plans = service.service_plans
  plans.default!(plans.default_or_first || plans.first)
  FactoryBot.create(:application_plan, name: 'Base', issuer: service, default: true)
end

When(/^the provider deletes the (account|application)(?: named "([^"]*)")?$/) do |account_or_service, account_or_application_name|
  account_or_application_name ||= account_or_service == 'application' ? "Alexisonfire" : "Alexander"

  object = if account_or_service == 'application'
             Application.find_by(name: account_or_application_name)
           else
             Account.find_by(name: account_or_application_name)
           end
  object.destroy
end

# This is a maze for your brain
# It means:
# - provider has a paid plan
# - provider enables the :require_cc_on_cc_signup switch in order force the buyer to fill in credit card first on paid plans.
When(/^the provider has credit card on signup feature in (automatic|manual) mode/) do |mode|
  @provider.stubs(:provider_can_use?).with(:require_cc_on_signup).returns(mode == 'manual')
end

When(/^the provider upgrades to plan "(.+?)"$/) do |name|
  plan = Plan.find_by_system_name(name)
  @provider.reload
  @provider.force_upgrade_to_provider_plan!(plan)
end

When(/I authenticate by Oauth2$/) do
  try_buyer_login_oauth
end

When "the buyer authenticates by OAuth2" do
  try_buyer_login_oauth
end

When "the buyer authenticates by token" do
  try_buyer_login_sso_token
end

And(/^the provider has one buyer$/) do
  @buyer = pending_buyer(@provider, 'bob')
  @buyer.approve! unless @buyer.approved?
end

And(/^the provider enables credit card on signup feature manually/) do
  settings = @provider.settings
  settings.allow_require_cc_on_signup! unless settings.require_cc_on_signup.allowed?
  settings.show_require_cc_on_signup!  unless settings.require_cc_on_signup.visible?
end

Given(/^master is the provider$/) do
  @provider = Account.master
  @service = @provider.default_service
  @provider.settings.allow_multiple_applications!
  @provider.settings.show_multiple_applications!
  FactoryBot.create(:application_plan, name: 'The Plan',
                                       issuer: @service,
                                       state: :published,
                                       default: true)
end

When "{provider} is suspended" do |provider|
  provider.suspend!
end

Then "I see the support email of {provider}" do |provider|
  assert_text ThreeScale.config.support_email
end

Given "{provider} has no users" do |provider|
  provider.users.each(&:delete)
end
