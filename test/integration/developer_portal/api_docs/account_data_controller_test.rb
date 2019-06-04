# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::ApiDocs::AccountDataControllerTest < ActionDispatch::IntegrationTest
  include DeveloperPortal::Engine.routes.url_helpers

  def setup
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    service = provider.default_service
    @application = FactoryBot.create(:cinstance, user_account: buyer, name: 'MyAppName', plan: FactoryBot.create(:application_plan, service: service, name: 'MyPlanName'))
    service.update!(backend_version: 2)
  end

  attr_reader :provider, :buyer, :application

  test 'JSON description of useful account data for buyer' do
    login_buyer buyer
    get api_docs_account_data_path(format: :json)

    assert_equal expected_json, JSON.parse(response.body).deep_symbolize_keys
  end

  test 'forbidden when user not logged in' do
    get api_docs_account_data_url(host: provider.domain, format: :json)

    assert_equal({status: 401}, JSON.parse(response.body).symbolize_keys)
  end

  def expected_json
    app_name = application.name
    service_name = application.service.name
    {
      results: {
        app_keys: [{name: "#{app_name} - #{service_name}", value: application.keys.first.to_s}],
        app_ids: [{name: "#{app_name} - #{service_name}", value: application.application_id}],
        user_keys: [], client_secrets: [], client_ids: []
      },
      status: 200
    }
  end
end
