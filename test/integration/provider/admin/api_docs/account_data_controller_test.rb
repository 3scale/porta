# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::ApiDocs::AccountDataControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @service = provider.default_service
    provider.settings.allow_multiple_applications!
    provider.settings.show_multiple_applications!
    @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    plan = FactoryBot.create(:application_plan, service: service, name: 'MyPlanName')
    @application = FactoryBot.create(:cinstance, user_account: buyer, plan: plan, name: 'MyAppName')

    service.update!(backend_version: 1)
    service.service_tokens.delete_all # ensure all service_tokens are cleaned up for this test
    @token = service.service_tokens.create!(value: 'foobar')

    @provider_admin = provider.admins.first
    @buyer_admin = buyer.admins.first!
    @metric = provider.metrics.first
    @application_plans = provider.application_plans.latest
    @account_plans = provider.account_plans.latest
    @service_plans = provider.service_plans.latest
  end

  attr_reader :provider, :service, :buyer, :token, :provider_admin, :buyer_admin, :application, :metric, :application_plans, :account_plans, :service_plans

  test 'JSON description of useful account data for provider' do
    login! provider
    get provider_admin_api_docs_account_data_path(format: :json)

    assert_response :ok
    assert_equal expected_json, JSON.parse(response.body).deep_symbolize_keys
  end

  test 'forbidden when user not logged in' do
    get provider_admin_api_docs_account_data_url(host: provider.self_domain, format: :json)

    assert_response :forbidden
  end

  def expected_json
    {
      results: {
        app_keys: [], app_ids: [], client_ids: [], client_secrets: [],
        user_keys: [{name: "#{application.name} - #{application.service.name}", value: application.user_key }],
        admin_ids: [{name: provider_admin.username, value: provider_admin.id}],
        metric_names: [{name: "#{metric.friendly_name} | #{metric.service.name}", value: metric.name}],
        metric_ids: [{name: "#{metric.friendly_name} | #{metric.service.name}", value: metric.id}],
        service_ids: [{name: service.name, value: service.id}],
        application_ids: [{name: "#{application.name} | #{application.service.name}", value: application.id}],
        account_ids: [{name: buyer.name, value: buyer.id}],
        user_ids: [{name: buyer_admin.username, value: buyer_admin.id}],
        service_plan_ids: [{name: "#{service_plans[0].name} | #{service_plans[0].service.name}", value: service_plans[0].id}],
        account_plan_ids: [{name: account_plans[0].name, value: account_plans[0].id}],
        application_plan_ids: [{name: "#{application_plans[0].name} | #{application_plans[0].service.name}", value: application_plans[0].id}],
        access_token: [{ name: 'First create an access token in the Personal Settings section.', value: ''}],
        service_tokens: [{ name: service.name, value: token.value }]
      },
      status: 200
    }
  end
end
