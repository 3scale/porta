# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ServiceSubscriptionsControllerTest < ActionDispatch::IntegrationTest
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
      get admin_api_account_service_subscriptions_path(account_id: buyer.id, format: :xml, access_token: token)
      assert_response :success

      xml = Nokogiri::XML::Document.parse(response.body)
      assert xml.xpath('/service_subscriptions/service_subscription/id').text == service_contract.id.to_s
    end

    test 'successful unsubscribe' do
      apps = buyer.bought_cinstances.by_service_id(service_contract.service_id)
      apps.update_all state: 'suspended'

      delete admin_api_account_service_subscription_path(service_contract.id, account_id: buyer.id, format: :xml, access_token: token)

      assert_response :success
      assert_raises(ActiveRecord::RecordNotFound) { service_contract.reload }
    end

    test 'unsubscribe forbidden' do
      delete admin_api_account_service_contract_path(service_contract.id, account_id: buyer.id, format: :xml, access_token: token)
      assert_response :forbidden
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
      get admin_api_account_service_subscriptions_path(account_id: buyer.id, format: :xml, access_token: token)
      assert_response :forbidden
    end

    test 'index works in SaaS' do
      get admin_api_account_service_subscriptions_path(account_id: buyer.id, format: :xml, access_token: token)
      assert_response :success
    end

    test 'delete is not authorized on-premises' do
      ThreeScale.stubs(master_on_premises?: true)
      apps = buyer.bought_cinstances.by_service_id(service_contract.service_id)
      apps.update_all state: 'suspended'
      delete admin_api_account_service_contract_path(service_contract.id, account_id: buyer.id, format: :xml, access_token: token)
      assert_response :forbidden
    end

    test 'delete works in SaaS' do
      apps = buyer.bought_cinstances.by_service_id(service_contract.service_id)
      apps.update_all state: 'suspended'
      delete admin_api_account_service_contract_path(service_contract.id, account_id: buyer.id, format: :xml, access_token: token)
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
