# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ServiceContractsControllerTest < ActionDispatch::IntegrationTest

  disable_transactional_fixtures!

  def setup
    @service_plan     = FactoryBot.create(:service_plan, issuer: service)
    @application_plan = FactoryBot.create(:application_plan, issuer: service)

    @buyer            = FactoryBot.create(:buyer_account, provider_account: current_account)
    @service_contract = FactoryBot.create(:simple_service_contract, plan: @service_plan, user_account: @buyer)

    @buyer.buy! @application_plan

    login! current_account
  end

  class ProviderAccountTest < Admin::Api::ServiceContractsControllerTest
    def test_index
      get admin_api_account_service_contracts_path(account_id: @buyer.id, format: :xml)
      assert_response :success

      xml = Nokogiri::XML::Document.parse(response.body)
      assert xml.xpath('.//service_contracts/service-contract/id').text == @service_contract.id.to_s
    end

    def test_success_unsubscribe
      apps = @buyer.bought_cinstances.by_service_id(@service_contract.service_id)
      apps.update_all state: 'suspended'

      delete admin_api_account_service_contract_path(@service_contract.id, account_id: @buyer.id, format: :xml)

      assert_response :success
      assert_raises(ActiveRecord::RecordNotFound) { @service_contract.reload }
    end

    def test_failure_unsubscribe
      delete admin_api_account_service_contract_path(@service_contract.id, account_id: @buyer.id, format: :xml)
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
      get admin_api_account_service_contracts_path(account_id: @buyer.id, format: :xml)
      assert_response :forbidden
    end

    def test_index_works_for_saas
      get admin_api_account_service_contracts_path(account_id: @buyer.id, format: :xml)
      assert_response :success
    end

    def test_delete_not_authorized_for_on_premises
      ThreeScale.stubs(master_on_premises?: true)
      apps = @buyer.bought_cinstances.by_service_id(@service_contract.service_id)
      apps.update_all state: 'suspended'
      delete admin_api_account_service_contract_path(@service_contract.id, account_id: @buyer.id, format: :xml)
      assert_response :forbidden
    end

    def test_delete_works_for_saas
      apps = @buyer.bought_cinstances.by_service_id(@service_contract.service_id)
      apps.update_all state: 'suspended'
      delete admin_api_account_service_contract_path(@service_contract.id, account_id: @buyer.id, format: :xml)
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
