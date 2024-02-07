# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ServiceContractsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @service_plan     = FactoryBot.create(:service_plan, issuer: service)
    @application_plan = FactoryBot.create(:application_plan, issuer: service)

    new_service = FactoryBot.create(:simple_service, account: current_account)
    @new_service_plan     = FactoryBot.create(:service_plan, issuer: new_service)
    @new_application_plan = FactoryBot.create(:application_plan, issuer: new_service)

    @buyer            = FactoryBot.create(:buyer_account, provider_account: current_account)
    @service_contract = FactoryBot.create(:simple_service_contract, plan: @service_plan, user_account: @buyer)

    @buyer.buy! @application_plan
    @buyer.buy! @new_application_plan

    @token = FactoryBot.create(:access_token, owner: current_account.admin_users.first!, scopes: 'account_management').value
    host! current_account.internal_admin_domain
  end

  class ProviderAccountTest < Admin::Api::ServiceContractsControllerTest
    def test_index
      get admin_api_account_service_contracts_path(account_id: @buyer.id, format: :xml, access_token: @token)
      assert_response :success

      xml = Nokogiri::XML::Document.parse(response.body)
      assert xml.xpath('.//service_contracts/service-contract/id').text == @service_contract.id.to_s
    end

    def test_show # to get a service contract
      get admin_api_account_service_contract_path(account_id: @buyer.id, format: :xml, access_token: @token, id: @service_contract.id)
      assert_response :success

      xml = Nokogiri::XML::Document.parse(response.body)
      assert xml.xpath('//service-contract/id').text == @service_contract.id.to_s
    end

    def test_success_subscribe
      post admin_api_account_service_contracts_path(
        account_id: @buyer.id,
        format: :xml,
        access_token: @token,
        service_contract: { plan_id: @new_service_plan.id }
      )
      assert_response :success
    end

    def test_already_subscribed
      post admin_api_account_service_contracts_path(
        account_id: @buyer.id,
        format: :xml,
        access_token: @token,
        service_contract: { plan_id: @service_plan.id }
      )
      assert_response :unprocessable_entity
      assert_match "already subscribed to this service", response.body
    end

    def test_failure_subscribe
       post admin_api_account_service_contracts_path(
        account_id: current_account.id,
        format: :xml,
        access_token: @token,
        service_contract: { plan_id: @service_plan.id }
      )
      assert_match "Buyer not found with this account ID", response.body
    end

    def test_success_unsubscribe
      apps = @buyer.bought_cinstances.by_service_id(@service_contract.service_id)
      apps.update_all state: 'suspended'

      delete admin_api_account_service_contract_path(@service_contract.id, account_id: @buyer.id, format: :xml, access_token: @token)

      assert_response :success
      assert_raises(ActiveRecord::RecordNotFound) { @service_contract.reload }
    end

    def test_failure_unsubscribe
      delete admin_api_account_service_contract_path(@service_contract.id, account_id: @buyer.id, format: :xml, access_token: @token)
      assert_response :forbidden
    end

    private

    def current_account
      @provider ||= FactoryBot.create(:provider_account, provider_account: master_account)
    end

    def service
      @service ||= FactoryBot.create(:service, account: current_account)
    end
  end

  class MasterAccountTest < Admin::Api::ServiceContractsControllerTest
    def test_index_not_authorized_for_on_premises
      ThreeScale.stubs(master_on_premises?: true)
      get admin_api_account_service_contracts_path(account_id: @buyer.id, format: :xml, access_token: @token)
      assert_response :forbidden
    end

    def test_index_works_for_saas
      get admin_api_account_service_contracts_path(account_id: @buyer.id, format: :xml, access_token: @token)
      assert_response :success
    end

    def test_delete_not_authorized_for_on_premises
      ThreeScale.stubs(master_on_premises?: true)
      apps = @buyer.bought_cinstances.by_service_id(@service_contract.service_id)
      apps.update_all state: 'suspended'
      delete admin_api_account_service_contract_path(@service_contract.id, account_id: @buyer.id, format: :xml, access_token: @token)
      assert_response :forbidden
    end

    def test_delete_works_for_saas
      apps = @buyer.bought_cinstances.by_service_id(@service_contract.service_id)
      apps.update_all state: 'suspended'
      delete admin_api_account_service_contract_path(@service_contract.id, account_id: @buyer.id, format: :xml, access_token: @token)
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
