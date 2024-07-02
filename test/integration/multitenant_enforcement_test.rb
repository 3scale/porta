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
    AccessToken.new.value
    get admin_api_service_application_plans_path(service_id: service.id, format: :json, access_token: token)
    assert_response :success
  end

  test "multitenant account can retrieve from multiple tenants by master key" do
    host! master_account.external_admin_domain
    service = master_account.first_service!
    plan = FactoryBot.create(:application_plan, issuer: service)
    service.update_column(:tenant_id, @provider.tenant_id)
    plan.update_column(:tenant_id, @provider.tenant_id + 1)
    get admin_api_service_application_plans_path(service_id: service.id, format: :json, provider_key: master_account.provider_key)
    assert_response :success
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
