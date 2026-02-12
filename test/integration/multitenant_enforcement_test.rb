# frozen_string_literal: true

require 'test_helper'

class MultitenantEnforcementTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
  end

  test "forbid retrieving objects from multiple tenants" do
    login! @provider
    service = @provider.first_service!
    plan = FactoryBot.create(:application_plan, issuer: service)
    plan.update_column(:tenant_id, @provider.tenant_id + 1)
    get admin_service_application_plans_path(service)
  rescue => exception
    assert_predicate exception, :cause
    assert_instance_of ThreeScale::Middleware::Multitenant::TenantChecker::TenantLeak, exception.cause
  end

  test "forbid retrieving from multiple tenants by token" do
    host! @provider.external_admin_domain
    service = @provider.first_service!
    plan = FactoryBot.create(:application_plan, issuer: service)
    plan.update_column(:tenant_id, @provider.tenant_id + 1)
    token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[account_management]).value
    assert_raises ThreeScale::Middleware::Multitenant::TenantChecker::TenantLeak do
      get admin_api_service_application_plans_path(service_id: service.id, format: :json, access_token: token)
    end
  end

  test "forbid retrieving from multiple tenants by provider key" do
    host! @provider.external_admin_domain
    service = @provider.first_service!
    plan = FactoryBot.create(:application_plan, issuer: service)
    plan.update_column(:tenant_id, @provider.tenant_id + 1)
    assert_raises ThreeScale::Middleware::Multitenant::TenantChecker::TenantLeak do
      get admin_api_service_application_plans_path(service_id: service.id, format: :json, provider_key: @provider.provider_key)
    end
  end

  test "allow retrieving objects with NULL tenant_id" do
    login! @provider
    service = @provider.first_service!
    plan = FactoryBot.create(:application_plan, issuer: service)
    plan.update_column(:tenant_id, nil)
    get admin_service_application_plans_path(service)
    assert_response :success
  end

  test "multitenant account can retrieve from multiple tenants by token" do
    host! master_account.external_admin_domain
    service = master_account.first_service!
    plan = FactoryBot.create(:application_plan, issuer: service)
    service.update_column(:tenant_id, @provider.tenant_id)
    plan.update_column(:tenant_id, @provider.tenant_id + 1)
    token = FactoryBot.create(:access_token, owner: master_account.admin_users.first!, scopes: %w[account_management]).value
    get admin_api_service_application_plans_path(service_id: service.id, format: :json, access_token: token)
    assert_response :success
    put admin_api_service_application_plan_path(service_id: service.id, id: plan.id, format: :json), params: {access_token: token, description: "desc1"}
    assert_response :success
  end

  test "multitenant master can retrieve from multiple tenants by http basic auth" do
    host! master_account.external_admin_domain
    service = master_account.first_service!
    plan = FactoryBot.create(:application_plan, issuer: service)
    service.update_column(:tenant_id, @provider.tenant_id)
    plan.update_column(:tenant_id, @provider.tenant_id + 1)

    token = FactoryBot.create(:access_token, owner: master_account.admin_users.first!, scopes: %w[account_management]).value
    auth_pair = []
    auth_pair << ["", token]
    auth_pair << [token, ""]
    auth_pair << ["", master_account.provider_key]
    auth_pair << [master_account.provider_key, ""]

    auth_pair.each do |pair|
      basic_auth_str = ActionController::HttpAuthentication::Basic.encode_credentials(*pair)
      get admin_api_service_application_plans_path(service_id: service.id, format: :json), headers: { 'HTTP_AUTHORIZATION' => basic_auth_str }
      assert_response :success
    end
  end

  test "multitenant master can retrieve from multiple tenants by provider key" do
    host! master_account.external_admin_domain
    service = master_account.first_service!
    plan = FactoryBot.create(:application_plan, issuer: service)
    service.update_column(:tenant_id, @provider.tenant_id)
    plan.update_column(:tenant_id, @provider.tenant_id + 1)
    get admin_api_service_application_plans_path(service_id: service.id, format: :json, provider_key: master_account.provider_key)
    assert_response :success
    put admin_api_service_application_plan_path(service_id: service.id, id: plan.id, format: :json), params: {provider_key: master_account.provider_key, description: "desc1"}
    assert_response :success
  end

  test "multitenant master retrieve from multiple tenants in master API by api_key in query" do
    proxies = FactoryBot.create_list(:proxy, 2)
    proxies.each do |proxy|
      FactoryBot.create_list(:proxy_config, 1, proxy: proxy, environment: 'sandbox')
      FactoryBot.create_list(:proxy_config, 1, proxy: proxy, environment: 'production')
    end
    proxies[1].update(tenant_id: proxies[0].reload.tenant_id + 1)

    host! master_account.internal_admin_domain
    get master_api_proxy_configs_path(environment: 'production', api_key: master_account.provider_key)
    assert_response :success
  end

  test "multitenant master retrieve from multiple tenants in master API by api_key in request" do
    User.any_instance.expects(:tenant_id).at_least(2).returns(@provider.reload.tenant_id)

    signup_params = {
      api_key: master_account.api_key,
      org_name: 'Alaska',
      username: 'person',
      email: 'person@example.com',
      password: 'superSecret1234#',
      user_extra_field: 'hi-user',
      account_extra_field: 'hi-account'
    }

    host! master_account.internal_admin_domain
    post master_api_providers_path, params: signup_params
    assert_response :created
  end

  test "multitenant account can retrieve from multiple tenants by user" do
    login! master_account
    service = master_account.first_service!
    plan = FactoryBot.create(:application_plan, issuer: service)
    service.update_column(:tenant_id, @provider.tenant_id)
    plan.update_column(:tenant_id, @provider.tenant_id + 1)
    get admin_service_application_plans_path(service)
    assert_response :success
  end
end
