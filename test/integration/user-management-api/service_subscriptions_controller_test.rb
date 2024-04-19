# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ServiceSubscriptionsControllerTest < ActionDispatch::IntegrationTest

  SERVICE_SUBSCRIPTION_ATTRIBUTES = %w[id plan_id service_id user_account_id created_at updated_at state paid_until trial_period_expires_at setup_fee type variable_cost_paid_until tenant_id].freeze

  def setup
    @service_plan     = FactoryBot.create(:service_plan, issuer: service)
    @application_plan = FactoryBot.create(:application_plan, issuer: service)

    @buyer            = FactoryBot.create(:buyer_account, provider_account: current_account)
    @service_contract = FactoryBot.create(:simple_service_contract, plan: @service_plan, user_account: @buyer)

    @buyer.buy! @application_plan

    @token = FactoryBot.create(:access_token, owner: current_account.admin_users.first!, scopes: 'account_management').value
    host! current_account.internal_admin_domain
  end

  attr_reader :buyer, :token, :service_contract

  class ProviderAccountTest < Admin::Api::ServiceSubscriptionsControllerTest
    test 'index' do
      another_plan = FactoryBot.create(:service_plan)
      another_service_contract = FactoryBot.create(:simple_service_contract, plan: another_plan, user_account: buyer)
      get admin_api_account_service_subscriptions_path(account_id: buyer.id, format: :json, access_token: token)
      assert_response :ok

      expected_ids = [service_contract.id, another_service_contract.id]
      json_body = JSON.parse(response.body)
      assert_equal expected_ids, (json_body['service_subscriptions'].map { |item| item['service_subscription']['id'] })
    end

    test 'successful unsubscribe' do
      apps = buyer.bought_cinstances.by_service_id(service_contract.service_id)
      apps.update_all state: 'suspended'

      delete admin_api_account_service_subscription_path(service_contract.id, account_id: buyer.id, format: :json, access_token: token)

      assert_response :ok
      assert_raises(ActiveRecord::RecordNotFound) { service_contract.reload }
    end

    test 'unsubscribe forbidden' do
      delete admin_api_account_service_subscription_path(service_contract.id, account_id: buyer.id, format: :json, access_token: token)
      assert_response :forbidden
    end

    test 'show' do
      get admin_api_account_service_subscription_path(service_contract.id, account_id: buyer.id, format: :json, access_token: token)
      assert_response :ok

      json_body = JSON.parse(response.body)
      assert_equal service_contract.id, json_body.dig('service_subscription', 'id')
      assert_same_elements SERVICE_SUBSCRIPTION_ATTRIBUTES, json_body['service_subscription'].keys
    end

    test 'subscribe successfully on another service' do
      another_service = FactoryBot.create(:service, account: current_account)
      another_service_plan = FactoryBot.create(:service_plan, issuer: another_service)
      post admin_api_account_service_subscriptions_path(account_id: buyer.id, format: :json, access_token: token),
           params: { plan_id: another_service_plan.id }
      assert_response :created

      json_body = JSON.parse(response.body)
      assert_equal another_service_plan.id, json_body.dig('service_subscription', 'plan_id')
    end

    test 'subscription on the same service fails' do
      another_service_plan = FactoryBot.create(:service_plan, issuer: service)
      post admin_api_account_service_subscriptions_path(account_id: buyer.id, format: :json, access_token: token),
           params: { plan_id: another_service_plan.id }
      assert_response :unprocessable_entity

      json_body = JSON.parse(response.body)
      assert_equal 'already subscribed to this service', json_body.dig('errors', 'base', 0)
    end

    test "subscription on other another provider's plan fails" do
      another_provider = FactoryBot.create(:provider_account, provider_account: master_account)
      another_service = FactoryBot.create(:service, account: another_provider)
      another_service_plan = FactoryBot.create(:service_plan, issuer: another_service)

      post admin_api_account_service_subscriptions_path(account_id: buyer.id, format: :json, access_token: token),
           params: { plan_id: another_service_plan.id }
      assert_response :not_found
    end

    test 'plan changed successfully' do
      another_service_plan = FactoryBot.create(:service_plan, issuer: service)

      put change_plan_admin_api_account_service_subscription_path(service_contract.id, account_id: buyer.id, format: :json, access_token: token),
          params: { plan_id: another_service_plan.id }
      assert_response :ok

      json_body = JSON.parse(response.body)
      assert_equal another_service_plan.id, json_body.dig('service_plan', 'id')
    end

    test "plan change fails for plan in another service" do
      another_service = FactoryBot.create(:service, account: current_account)
      another_service_plan = FactoryBot.create(:service_plan, issuer: another_service)

      put change_plan_admin_api_account_service_subscription_path(service_contract.id, account_id: buyer.id, format: :json, access_token: token),
          params: { plan_id: another_service_plan.id }
      assert_response :unprocessable_entity

      json_body = JSON.parse(response.body)
      assert_equal 'must belong to the same product', json_body.dig('errors', 'plan', 0)
    end

    test 'approve pending subscription' do
      plan_with_approval = FactoryBot.create(:service_plan, approval_required: true)
      subscription = FactoryBot.create(:simple_service_contract, plan: plan_with_approval, user_account: buyer)

      assert 'pending', subscription.state

      put approve_admin_api_account_service_subscription_path(subscription.id, account_id: buyer.id, format: :json, access_token: token)
      assert_response :ok

      json_body = JSON.parse(response.body)
      assert_equal 'live', json_body.dig('service_subscription', 'state')
    end

    test 'approval fails if incorrect state' do
      plan_with_approval = FactoryBot.create(:service_plan, approval_required: true)
      subscription = FactoryBot.create(:simple_service_contract, plan: plan_with_approval, user_account: buyer)

      assert 'pending', subscription.state

      subscription.update_attribute('state', 'live')

      put approve_admin_api_account_service_subscription_path(subscription.id, account_id: buyer.id, format: :json, access_token: token)
      assert_response :unprocessable_entity

      json_body = JSON.parse(response.body)
      assert_not_empty json_body.dig('errors', 'state')
    end

    private

    def current_account
      @current_account ||= FactoryBot.create(:provider_account, provider_account: master_account)
    end

    def service
      @service ||= FactoryBot.create(:service, account: current_account)
    end
  end

  class MasterAccountTest < Admin::Api::ServiceSubscriptionsControllerTest
    test 'index is not authorized in on-premises' do
      ThreeScale.stubs(master_on_premises?: true)
      get admin_api_account_service_subscriptions_path(account_id: buyer.id, format: :json, access_token: token)
      assert_response :forbidden
    end

    test 'index works in SaaS' do
      get admin_api_account_service_subscriptions_path(account_id: buyer.id, format: :json, access_token: token)
      assert_response :success
    end

    test 'delete is not authorized on-premises' do
      ThreeScale.stubs(master_on_premises?: true)
      apps = buyer.bought_cinstances.by_service_id(service_contract.service_id)
      apps.update_all state: 'suspended'
      delete admin_api_account_service_contract_path(service_contract.id, account_id: buyer.id, format: :json, access_token: token)
      assert_response :forbidden
    end

    test 'delete works in SaaS' do
      apps = buyer.bought_cinstances.by_service_id(service_contract.service_id)
      apps.update_all state: 'suspended'
      delete admin_api_account_service_contract_path(service_contract.id, account_id: buyer.id, format: :json, access_token: token)
      assert_response :success
    end

    private

    def current_account
      master_account
    end

    def service
      @service ||= master_account.first_service!
    end
  end
end
