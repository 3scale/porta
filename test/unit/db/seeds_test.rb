# frozen_string_literal: true

require 'test_helper'

class SeedsTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  ENV_VARIABLES = {
    'MASTER_NAME' => 'master name',
    'MASTER_DOMAIN' => 'master-domain',
    'MASTER_ACCESS_CODE' => 'my_access_code',
    'MASTER_USER' => 'my-username',
    'MASTER_SERVICE' => 'the master service',
    'MASTER_PLAN' => 'the master plan',

    'PROVIDER_NAME' => 'tenant account name',
    'TENANT_NAME' => 'provider-subdomain',
    'SAMPLE_DATA' => '0',
    'USER_LOGIN' => 'adminuser',
    'USER_EMAIL' => 'myemail@example.com',
    'PROVIDER_PLAN' => 'pro-plan',
    'CMS_TEMPLATES' => '1'
  }

  def setup
    EventStore::Repository.stubs(raise_errors: true)
  end

  def teardown
    EventStore::Repository.stubs(raise_errors: false)
    ENV_VARIABLES.each { |env_name, _env_value| ENV[env_name] = nil }
  end

  test 'default values' do
    FieldsDefinition.expects(:create_defaults!).with(&:master?)
    FieldsDefinition.expects(:create_defaults!).with(&:tenant?)
    SignupWorker.expects(:enqueue).with(&:tenant?)
    SimpleLayout.any_instance.expects(:import!).never


    Rails.application.load_seed


    #### MASTER

    master_account = Account.master
    assert master_account.approved?
    assert master_account.state_changed_at.present?
    assert_equal master_account.id, master_account.provider_account_id
    assert_equal 'Master Account', master_account.name
    assert_equal 'master-account', master_account.subdomain
    assert_equal 'master-account.example.com', master_account.internal_domain
    assert_equal 'master-account.example.com', master_account.internal_admin_domain
    refute master_account.provider
    assert_nil master_account.site_access_code.presence

    assert master_account.settings.branding.allowed?
    assert master_account.settings.account_plans.visible?
    assert master_account.settings.service_plans.visible?

    assert_equal 1, master_account.users.count
    master_user = master_account.users.first!
    assert_equal 'master', master_user.username
    assert master_user.minimal_signup?
    assert master_user.admin?
    assert master_user.active?
    assert master_user.activated_at.present?

    assert_equal 1, master_account.services.count
    master_service = master_account.default_service
    assert_equal 'Master Service', master_service.name
    range = [0] | Alert::ALERT_LEVELS
    assert_equal({ web_buyer: range, email_buyer: range, web_provider: range, email_provider: range}, master_service.notification_settings)
    assert_equal 'self_managed', master_service.deployment_option

    assert master_service.default_service_plan

    assert_equal 1, master_service.backend_apis.count
    assert_equal BackendApi.default_api_backend, master_service.backend_apis.first!.private_endpoint

    master_app_plan = master_service.default_application_plan
    assert_equal master_service.id, master_app_plan.issuer_id
    assert_equal 'enterprise', master_app_plan.name

    assert_equal ApplicationPlan.find_by(name: 'Master Plan').id, master_account.bought_cinstance.plan_id

    master_account_plan = master_account.default_account_plan
    assert_equal master_account.id, master_account_plan.issuer_id
    assert_equal 'Default account plan', master_account_plan.name

    {billing: 'Billing API', account: 'Account Management API', analytics: 'Analytics API'}.each do |system_name, description|
      assert master_service.metrics.find_by(system_name: system_name, unit: 'hit', friendly_name: description)
    end

    tenant_app_plan = master_service.application_plans.default
    assert_equal 'enterprise', tenant_app_plan.name
    assert_equal master_service.id, tenant_app_plan.issuer_id

    apicast = master_account.access_tokens.find_by(name: 'APIcast')
    assert_equal 'ro', apicast.permission
    assert_equal %w[account_management], apicast.scopes
    master_token = master_account.access_tokens.find_by(name: 'Master Token')
    assert_equal 'rw', master_token.permission
    assert_equal %w[account_management], master_token.scopes

    #### TENANT

    assert_equal 1, Account.tenants.count
    tenant_account = Account.tenants.first!
    assert_equal Account.master.id, tenant_account.provider_account_id
    assert tenant_account.onboarding
    assert_equal 'provider', tenant_account.subdomain
    assert_equal 'provider.example.com', tenant_account.internal_domain
    assert_equal 'provider-admin.example.com', tenant_account.internal_admin_domain
    assert tenant_account.sample_data.presence
    assert tenant_account.approved?
    assert tenant_account.state_changed_at.present?
    assert_equal ApplicationPlan.find_by(name: 'enterprise').id, tenant_account.bought_cinstance.plan_id
    assert_equal 'API', tenant_account.default_service.name

    assert_equal 2, tenant_account.users.count
    tenant_user = tenant_account.users.but_impersonation_admin.first!
    assert tenant_user.minimal_signup?
    assert tenant_user.admin?
    assert tenant_user.active?
    assert tenant_user.activated_at.present?
    assert_equal 'admin', tenant_user.username
    assert_equal 'admin@provider.example.com', tenant_user.email

    impersonation_user = tenant_account.users.impersonation_admin!
    impersonation_admin_config = ThreeScale.config.impersonation_admin
    assert impersonation_user.minimal_signup?
    assert impersonation_user.admin?
    assert impersonation_user.active?
    assert impersonation_user.activated_at.present?
    assert_equal impersonation_admin_config['username'], impersonation_user.username
    assert_equal "#{impersonation_admin_config['username']}+#{tenant_account.internal_admin_domain}@#{impersonation_admin_config['domain']}", impersonation_user.email
    assert_equal '3scale', impersonation_user.first_name
    assert_equal 'Admin', impersonation_user.last_name

    tenant_service = Account.tenants.first!.default_service
    assert_equal 1, tenant_service.backend_apis.count
    tenant_backend_api = tenant_service.backend_apis.accessible.first
    assert_equal BackendApi.default_api_backend, tenant_backend_api.private_endpoint
    assert_equal tenant_service.system_name, tenant_backend_api.system_name
    assert_equal "#{tenant_service.name} Backend", tenant_backend_api.name
    assert_equal "Backend of #{tenant_service.name}", tenant_backend_api.description
    assert_equal tenant_service.account_id, tenant_backend_api.account_id

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
    SimpleLayout.any_instance.expects(:import!) # This should test that it is for the tenant, but it is not easy.


    Rails.application.load_seed


    master_account = Account.master
    assert_equal ENV_VARIABLES['MASTER_NAME'], master_account.name
    assert_equal ENV_VARIABLES['MASTER_DOMAIN'], master_account.subdomain
    assert_equal "#{ENV_VARIABLES['MASTER_DOMAIN']}.example.com", master_account.internal_domain
    assert_equal "#{ENV_VARIABLES['MASTER_DOMAIN']}.example.com", master_account.internal_admin_domain
    assert_equal ENV_VARIABLES['MASTER_ACCESS_CODE'], master_account.site_access_code
    assert_equal ENV_VARIABLES['MASTER_USER'], master_account.users.first!.username
    assert_equal ENV_VARIABLES['MASTER_SERVICE'], master_account.default_service.name
    assert_equal ENV_VARIABLES['PROVIDER_PLAN'], master_account.default_service.application_plans.default.name
    assert_equal ApplicationPlan.find_by(name: ENV_VARIABLES['MASTER_PLAN']).id, master_account.bought_cinstance.plan_id

    tenant_account = Account.tenants.first!
    assert_equal ENV_VARIABLES['PROVIDER_NAME'], tenant_account.name
    assert_equal ENV_VARIABLES['TENANT_NAME'], tenant_account.subdomain
    assert_equal "#{ENV_VARIABLES['TENANT_NAME']}.example.com", tenant_account.internal_domain
    assert_equal "#{ENV_VARIABLES['TENANT_NAME']}-admin.example.com", tenant_account.internal_admin_domain
    assert_nil tenant_account.sample_data.presence
    tenant_user = tenant_account.users.but_impersonation_admin.first!
    assert_equal ENV_VARIABLES['USER_LOGIN'], tenant_user.username
    assert_equal ENV_VARIABLES['USER_EMAIL'], tenant_user.email
    assert_equal ApplicationPlan.find_by(name: ENV_VARIABLES['PROVIDER_PLAN']).id, tenant_account.bought_cinstance.plan_id
  end

  test 'done in a transaction: if it fails somewhere, it rollbacks' do
    Account.any_instance.expects(:force_upgrade_to_provider_plan!).raises(StandardError) # the method and the type of error are arbitrary, it could be any :)

    assert_raises(StandardError) { Rails.application.load_seed }

    [Account, User, Service, Plan, AccessToken, Metric, CMS::Template].each do |model|
      assert_equal 0, model.count, "#{model} did not rollback"
    end
  end
end
