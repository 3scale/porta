# frozen_string_literal: true

require 'test_helper'

class Buyers::ServiceContractsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account, provider_account: master_account)
    @service = FactoryBot.create(:service, account: provider)
    @service_plan = FactoryBot.create(:service_plan, issuer: service)
    @application_plan = FactoryBot.create(:application_plan, issuer: service)

    @buyer1 = FactoryBot.create(:buyer_account, provider_account: provider)
    @buyer2 = FactoryBot.create(:buyer_account, provider_account: provider)

    @service_contract = FactoryBot.create(:simple_service_contract, plan: service_plan, user_account: buyer1)

    buyer1.buy!(application_plan)
    buyer2.buy!(application_plan)
  end

  attr_reader :provider, :service, :service_plan, :application_plan, :buyer1, :buyer2, :service_contract

  class ProviderAdminTest < self
    setup do
      login! provider
    end

    test 'can unsubscribe from service contract' do
      get admin_buyers_account_service_contracts_path(account_id: buyer1.id)
      assert_response :success

      page = Nokogiri::HTML::Document.parse(response.body)

      assert page.xpath("//a[@class='button-to action edit fancybox change_plan']").text =~ /Change\ Plan/
      assert page.xpath("//a[@data-method='delete']").text =~ /Unsubscribe/
    end

    test 'unsubscribe developers from service with suspended application' do
      apps = buyer1.bought_cinstances.by_service_id(service_contract.service_id)
      apps.update_all state: 'suspended'

      delete admin_buyers_account_service_contract_path(service_contract.id, account_id: buyer1.id), headers: { 'HTTP_REFERER' => admin_buyers_service_contracts_path }

      assert_response :redirect
      assert_equal 0, apps.size
      assert_raise(ActiveRecord::RecordNotFound) do
        service_contract.reload
      end
      assert_equal 1, buyer2.bought_cinstances.by_service_id(service_contract.service_id).count
    end

    test 'unsubscribe developers from service with one not suspended application' do
      apps = buyer1.bought_cinstances.by_service_id(service_contract.service_id)

      assert_no_difference(-> {apps.count})  do
        delete admin_buyers_account_service_contract_path(service_contract.id, account_id: buyer1.id), headers: { 'HTTP_REFERER' => admin_buyers_service_contracts_path }

        assert_response :redirect
        assert_match I18n.t('service_contracts.unsubscribe_failure'), flash[:error]
      end
    end

    test 'unsubscribe developers from service with two not suspended applications' do
      application_plan2 = FactoryBot.create(:application_plan, issuer: service)

      buyer1.buy! application_plan2
      delete admin_buyers_account_service_contract_path(service_contract.id, account_id: buyer1.id), headers: { 'HTTP_REFERER' => admin_buyers_service_contracts_path }

      assert_response :redirect
      assert_match I18n.t('service_contracts.unsubscribe_failure'), flash[:error]
    end

    test 'unauthorized access master_on_premises' do
      login! master_account
      ThreeScale.stubs(master_on_premises?: true)
      get admin_buyers_account_service_contracts_path(account_id: provider.id)
      assert_response :forbidden
    end

    test 'renders a prompt if there is no default service plan' do
      get new_admin_buyers_account_service_contract_path(account_id: buyer1.id, service_id: service.id)

      page = Nokogiri::HTML::Document.parse(response.body)
      assert page.xpath("//select[@id='service_contract_plan_id']/option").map(&:text).include?('Please select')
    end

    test 'does not render a prompt if there is a default service plan' do
      service.update_attributes(default_service_plan: service_plan)

      get new_admin_buyers_account_service_contract_path(account_id: buyer1.id, service_id: service.id)

      page = Nokogiri::HTML::Document.parse(response.body)
      assert page.xpath("//select[@id='service_contract_plan_id']/option").map(&:text).exclude?('Please select')
    end
  end

  class ProviderMemberTest < self
    setup do
      @forbidden_service = FactoryBot.create(:simple_service, account: provider)
      @forbidden_service_plan = FactoryBot.create(:service_plan, name: 'Forbidden Plan', state: 'published', service: forbidden_service)
      @forbidden_service_contract = FactoryBot.create(:simple_service_contract, plan: forbidden_service_plan, user_account: buyer1)

      @member = FactoryBot.create(:member, account: provider, member_permission_ids: ['plans'])
      member.member_permission_service_ids = [service.id]
      member.activate!

      login!(provider, user: member)
    end

    attr_reader :member, :forbidden_service, :forbidden_service_plan, :forbidden_service_contract

    test 'index' do
      get admin_buyers_service_contracts_path
      assert_response :forbidden

      member.member_permission_ids = ['partners']
      member.save!

      get admin_buyers_service_contracts_path
      assert_response :success
      page = Nokogiri::HTML::Document.parse(response.body)
      service_contract_ids = page.xpath("//table[@class='data']/tbody/tr/@id").map { |id| id.text[/\d+/].to_i }
      assert_includes service_contract_ids, service_contract.id
      assert_not_includes service_contract_ids, forbidden_service_contract.id
    end

    test 'new' do
      request_options = ->(service) {
        { params: { service_id: service.id } }
      }

      get new_admin_buyers_account_service_contract_path(account_id: buyer1.id), params: request_options.call(service)
      assert_response :forbidden

      member.member_permission_ids = ['partners']
      member.save!

      get new_admin_buyers_account_service_contract_path(account_id: buyer1.id), params: request_options.call(service)
      assert_response :success

      get new_admin_buyers_account_service_contract_path(account_id: buyer1.id), params: request_options.call(forbidden_service)
      assert_response :not_found
    end

    test 'create' do
      other_service_plan = FactoryBot.create(:service_plan, issuer: service, name: 'Service Plan B')
      request_options = ->(service, plan) {
        {
          params: {
            service_id: service.id,
            service_contract: { plan_id: plan.id }
          },
          xhr: true
        }
      }

      post admin_buyers_account_service_contracts_path(account_id: buyer1.id), params: request_options.call(service, other_service_plan)
      assert_response :forbidden

      member.member_permission_ids = ['partners']
      member.save!

      post admin_buyers_account_service_contracts_path(account_id: buyer1.id), params: request_options.call(service, other_service_plan)
      assert_response :success

      post admin_buyers_account_service_contracts_path(account_id: buyer1.id), params: request_options.call(forbidden_service, forbidden_service_plan)
      assert_response :not_found
    end

    test 'edit' do
      get edit_admin_buyers_account_service_contract_path(service_contract.id, account_id: buyer1.id)
      assert_response :forbidden

      member.member_permission_ids = ['partners']
      member.save!

      get edit_admin_buyers_account_service_contract_path(service_contract.id, account_id: buyer1.id)
      assert_response :success

      get edit_admin_buyers_account_service_contract_path(forbidden_service_contract.id, account_id: buyer1.id)
      assert_response :not_found
    end

    test 'update' do
      other_service_plan = FactoryBot.create(:service_plan, issuer: service, name: 'Service Plan B')
      request_options = ->(service_plan) {
        {
          params: { service_contract: { plan_id: service_plan.id } },
          xhr: true
        }
      }

      put admin_buyers_account_service_contract_path(service_contract.id, account_id: buyer1.id), params: request_options.call(other_service_plan)
      assert_response :forbidden

      member.member_permission_ids = ['partners']
      member.save!

      put admin_buyers_account_service_contract_path(service_contract.id, account_id: buyer1.id), params: request_options.call(other_service_plan)
      assert_response :success

      put admin_buyers_account_service_contract_path(service_contract.id, account_id: buyer1.id), params: request_options.call(forbidden_service_plan)
      assert_response :not_found

      put admin_buyers_account_service_contract_path(forbidden_service_contract.id, account_id: buyer1.id), params: request_options.call(other_service_plan)
      assert_response :not_found
    end

    test 'approve' do
      request_options = { headers: { 'HTTP_REFERER' => admin_buyers_service_contracts_path } }

      post approve_admin_buyers_account_service_contract_path(service_contract.id, account_id: buyer1.id), params: request_options
      assert_response :forbidden

      member.member_permission_ids = ['partners']
      member.save!

      post approve_admin_buyers_account_service_contract_path(service_contract.id, account_id: buyer1.id), params: request_options
      assert_response :redirect

      post approve_admin_buyers_account_service_contract_path(forbidden_service_contract.id, account_id: buyer1.id), params: request_options
      assert_response :not_found
    end

    test 'unsubscribe' do
      buyer1.bought_cinstances.by_service_id(service_contract.service_id).update_all(state: 'suspended')
      request_options = { headers: { 'HTTP_REFERER' => admin_buyers_service_contracts_path } }

      delete admin_buyers_account_service_contract_path(service_contract.id, account_id: buyer1.id), params: request_options
      assert_response :forbidden

      member.member_permission_ids = ['partners']
      member.save!

      delete admin_buyers_account_service_contract_path(service_contract.id, account_id: buyer1.id), params: request_options
      assert_response :redirect
      assert_raise(ActiveRecord::RecordNotFound) { service_contract.reload }

      delete admin_buyers_account_service_contract_path(forbidden_service_contract.id, account_id: buyer1.id), params: request_options
      assert_response :not_found
    end
  end
end
