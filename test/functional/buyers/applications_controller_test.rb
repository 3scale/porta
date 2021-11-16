# frozen_string_literal: true

require 'test_helper'

class Buyers::ApplicationsControllerTest < ActionController::TestCase
  include WebHookTestHelpers

  setup do
    @plan = FactoryBot.create(:published_plan)
    @service = @plan.service
    @provider = @plan.service.account
    login_as(@provider.admins.first)
    host! @provider.self_domain
  end

  test 'do not create an application without a name' do
    service_plan = FactoryBot.create(:service_plan, service: @service)
    buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)

    assert_no_difference Cinstance.method(:count) do
      post :create, params: { account_id: buyer.id, cinstance: {
        plan_id: @plan.id, service_plan_id: service_plan.id
      } }
    end
    assert_response 200
  end

  test 'create application with a name' do
    service_plan = FactoryBot.create(:service_plan, service: @service)
    buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)

    assert_difference Cinstance.method(:count) do
      post :create, params: { account_id: buyer.id, cinstance: {
        plan_id: @plan.id, service_plan_id: service_plan.id,
        name: 'whatever'
      } }
    end
    assert_response :redirect
  end

  test "creates app with a specific service_plan" do
    service_plan = FactoryBot.create(:service_plan, service: @service)
    service_plan2 = FactoryBot.create(:service_plan, service: @service)

    buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)

    post :create, params: { account_id: buyer.id, cinstance: {
      name: 'whatever', plan_id: @plan.id, service_plan_id: service_plan2.id
    } }

    buyer.reload
    assert buyer.bought_service_contracts.map(&:service_plan).include?(service_plan2), "Should include the service_plan2"
  end

  test "creates app with a specific service_plan should not duplicate bought_service_contracts" do
    service_plan = FactoryBot.create(:service_plan, service: @service)
    buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)

    post :create, params: { account_id: buyer.id, cinstance: {
      name: 'whatever', plan_id: @plan.id, service_plan_id: service_plan.id
    } }

    buyer.reload
    assert_equal buyer.bought_service_contracts.count, 1

    post :create, params: { account_id: buyer.id, cinstance: {
      name: 'whatever', plan_id: @plan.id, service_plan_id: service_plan.id
    } }

    buyer.reload
    assert_equal buyer.bought_service_contracts.count, 1
  end

  class NoTransaction < ActionController::TestCase
    include WebHookTestHelpers

    setup do
      @plan = FactoryBot.create(:published_plan)
      @service = @plan.service
      @provider = @plan.service.account
      login_as(@provider.admins.first)
      host! @provider.self_domain
    end

    disable_transactional_fixtures!

    # regression test for GH Bug #1933
    test 'creates app with webhook enabled' do
      Account.any_instance.stubs(:web_hooks_allowed?).returns(true)

      webhook = FactoryBot.create(:webhook, :account => @provider)
      @service.update_attribute :backend_version, 2
      buyer = FactoryBot.create(:buyer_account, :provider_account => @provider)
      buyer.bought_service_contracts.create! :plan => @service.service_plans.first

      all_hooks_are_on(webhook)
      WebHookWorker.clear

      ThreeScale::Core::Application.stubs(:save).with do |params|
        fake_backend_get_keys('key', params[:id], params[:service_id], @provider.api_key)
      end

      post :create, params: { account_id: buyer.id, cinstance: {
        name: 'whatever', plan_id: @plan.id
      } }

      assert_response :redirect

      assert_not_empty WebHookWorker.jobs
    end

    private

    def fake_backend_get_keys(result, application_id, service_id, provider_key)
      keys = Array(result).map do |k|
        %(<key value="#{k}" href="http://example.org/applications/#{application_id}/keys.xml?provider_key=#{provider_key}&service_id=#{service_id}"/>)
      end

      stub_request(:get, "http://example.org/applications/#{application_id}/keys.xml?provider_key=#{provider_key}&service_id=#{service_id}")
        .to_return(status: 200, body: "<keys>#{keys.join("\n")}</keys>")
    end
  end

end
