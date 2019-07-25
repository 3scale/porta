# frozen_string_literal: true

require 'test_helper'

class SeedsTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  ENV_VARIABLES = {
    'MASTER_NAME' => 'master name',
    'MASTER_DOMAIN' => 'master-domain',
    'MASTER_ACCESS_CODE' => 'my_access_code',
    'MASTER_USER' => 'my-username',
    'MASTER_PASSWORD' => 'my-password',
    'MASTER_SERVICE' => 'the master service',
    'MASTER_PLAN' => 'the master plan',

    'PROVIDER_NAME' => 'tenant account name',
    'TENANT_NAME' => 'provider-subdomain',
    'SAMPLE_DATA' => '0',
    'USER_LOGIN' => 'adminuser',
    'USER_EMAIL' => 'myemail@example.com',
    'USER_PASSWORD' => 'mypass',
    'PROVIDER_PLAN' => 'pro-plan',
    'CMS_TEMPLATES' => '1'
  }

  def teardown
    ENV_VARIABLES.each { |env_name, _env_value| ENV[env_name] = nil }
  end

  # TODO: Test the ENVs: APICAST_ACCESS_TOKEN MASTER_ACCESS_TOKEN ADMIN_ACCESS_TOKEN
  # TODO: test password?
  # TODO: test provider.force_upgrade_to_provider_plan!(plan)

  test 'default values' do
    FieldsDefinition.expects(:create_defaults!).with(&:master?)
    FieldsDefinition.expects(:create_defaults!).with(&:tenant?)
    SignupWorker.expects(:enqueue).with(&:tenant?)
    SimpleLayout.any_instance.expects(:import!).never


    Rails.application.load_seed


    #### MASTER

    master_account = Account.master
    assert master_account.approved?
    assert_equal master_account.id, master_account.provider_account_id
    assert_equal 'Master Account', master_account.name
    assert_equal 'master-account', master_account.subdomain
    assert_equal 'master-account.example.com', master_account.domain
    assert_equal 'master-account.example.com', master_account.self_domain
    refute master_account.provider
    assert_nil master_account.site_access_code.presence

    assert master_account.settings.branding.allowed?
    assert master_account.settings.end_users.visible?
    assert master_account.settings.account_plans.visible?
    assert master_account.settings.service_plans.visible?

    assert_equal 1, master_account.users.count
    master_user = master_account.users.first!
    assert_equal 'master', master_user.username
    assert master_user.minimal_signup?
    assert master_user.admin?
    assert master_user.active?

    assert_equal 1, master_account.services.count
    master_service = master_account.default_service
    assert_equal 'Master Service', master_service.name
    range = [0] | Alert::ALERT_LEVELS
    assert_equal({ web_buyer: range, email_buyer: range, web_provider: range, email_provider: range}, master_service.notification_settings)
    assert_equal 'self_managed', master_service.deployment_option

    assert master_service.default_service_plan

    master_app_plan = master_service.default_application_plan
    assert_equal master_service.id, master_app_plan.issuer_id
    assert_equal 'enterprise', master_app_plan.name
    # assert_equal [master_app_plan.id], master_account.bought_application_plans.pluck(:id) # TODO: test: application_plan.create_contract_with! master

    master_account_plan = master_account.default_account_plan
    assert_equal master_account.id, master_account_plan.issuer_id
    assert_equal 'Default account plan', master_account_plan.name

    {billing: 'Billing API', account: 'Account Management API', analytics: 'Analytics API'}.each do |system_name, description|
      assert master_service.metrics.find_by(system_name: system_name, unit: 'hit', friendly_name: description)
    end

    assert(tenant_app_plan = master_service.application_plans.default)
    assert_equal 'enterprise', tenant_app_plan.name
    assert_equal master_service.id, tenant_app_plan.issuer_id

    assert(apicast = master_account.access_tokens.find_by(name: 'APIcast'))
    assert_equal 'ro', apicast.permission
    assert_equal %w[account_management], apicast.scopes
    assert(master_token = master_account.access_tokens.find_by(name: 'Master Token'))
    assert_equal 'rw', master_token.permission
    assert_equal %w[account_management], master_token.scopes

    #### TENANT

    assert_equal 1, Account.tenants.count
    tenant_account = Account.tenants.first!
    assert_equal Account.master.id, tenant_account.provider_account_id
    assert tenant_account.onboarding
    assert_equal 'provider', tenant_account.subdomain
    assert_equal 'provider.example.com', tenant_account.domain
    assert_equal 'provider-admin.example.com', tenant_account.self_domain
    assert tenant_account.sample_data.presence

    assert_equal 2, tenant_account.users.count
    tenant_user = tenant_account.users.but_impersonation_admin.first!
    assert tenant_user.minimal_signup?
    assert tenant_user.admin?
    assert tenant_user.active?
    assert_equal 'admin', tenant_user.username
    assert_equal 'admin@provider.example.com', tenant_user.email

    impersonation_user = tenant_account.users.impersonation_admin!
    impersonation_admin_config = ThreeScale.config.impersonation_admin
    assert impersonation_user.minimal_signup?
    assert impersonation_user.admin?
    assert impersonation_user.active?
    assert_equal impersonation_admin_config['username'], impersonation_user.username
    assert_equal "#{impersonation_admin_config['username']}+#{tenant_account.self_domain}@#{impersonation_admin_config['domain']}", impersonation_user.email
    assert_equal '3scale', impersonation_user.first_name
    assert_equal 'Admin', impersonation_user.last_name

    Settings.basic_enabled_switches.each do |switch_name|
      assert provider.settings.public_send(switch_name).visible?
    end

    Settings.basic_disabled_switches.each do |switch_name|
      assert provider.settings.public_send(switch_name).hidden?
    end
  end

  test 'with ENV as params' do
    ENV_VARIABLES.each { |env_name, env_value| ENV[env_name] = env_value }


    SignupWorker.expects(:enqueue).with(&:tenant?)
    SimpleLayout.any_instance.expects(:import!).once # TODO: test that the instance is the tenant


    Rails.application.load_seed


    master_account = Account.master
    assert_equal 'master name', master_account.name
    assert_equal 'master-domain', master_account.subdomain
    assert_equal 'master-domain.example.com', master_account.domain
    assert_equal 'master-domain.example.com', master_account.self_domain
    assert_equal 'my_access_code', master_account.site_access_code
    assert_equal 'my-username', master_account.users.first!.username
    assert_equal 'the master service', master_account.default_service.name
    assert(tenant_app_plan = master_account.default_service.application_plans.default)
    assert_equal 'pro-plan', tenant_app_plan.name

    tenant_account = Account.tenants.first!
    assert_equal 'provider-subdomain', tenant_account.subdomain
    assert_equal 'provider-subdomain.example.com', tenant_account.domain
    assert_equal 'provider-subdomain-admin.example.com', tenant_account.self_domain
    assert_nil tenant_account.sample_data.presence
    tenant_user = tenant_account.users.but_impersonation_admin.first!
    assert_equal 'adminuser', tenant_user.username
    assert_equal 'myemail@example.com', tenant_user.email
  end

  test 'done in a transaction: if it fails somewhere, it rollbacks' do
    Account.any_instance.expects(:force_upgrade_to_provider_plan!).raises(StandardError) # the method and the type of error are arbitrary, it could be any :)

    assert_raises(StandardError) { Rails.application.load_seed }

    [Account, User, Service, Plan, AccessToken, Metric, CMS::Template].each do |model|
      assert_equal 0, model.count, "#{model} did not rollback"
    end
  end
end
