# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::BackendApis::MappingRulesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account, :with_default_backend_api)
    @backend_api = @provider.first_service.backend_api

    FactoryBot.create(:proxy_rule, proxy: nil, owner: @backend_api)

    login_provider @provider
  end

  attr_reader :provider, :backend_api

  test '#index' do
    get provider_admin_backend_api_mapping_rules_path(backend_api)

    assert_response :success
    assert_select 'table.data tr', count: @backend_api.mapping_rules.count+2
    @backend_api.mapping_rules.each { |rule| assert_select 'table.data tr td', text: rule.pattern }
  end

  test 'it cannot operate under non-accessible backend api' do
    backend_api = FactoryBot.create(:backend_api, account: @provider, state: :deleted)

    get provider_admin_backend_api_mapping_rules_path(backend_api)
    assert_response :not_found

    post provider_admin_backend_api_mapping_rules_path(backend_api), {}
    assert_response :not_found

    get new_provider_admin_backend_api_mapping_rule_path(backend_api)
    assert_response :not_found

    get edit_provider_admin_backend_api_mapping_rule_path(backend_api, @backend_api.mapping_rules.first)
    assert_response :not_found

    put provider_admin_backend_api_mapping_rule_path(backend_api, @backend_api.mapping_rules.first), {}
    assert_response :not_found
  end

  test '#index should not render the Redirect column in the table' do
    get provider_admin_backend_api_mapping_rules_path(backend_api)

    assert_response :success
    refute_match /Redirect/, response.body
  end

  test '#new should not return the Redirect Url' do
    get new_provider_admin_backend_api_mapping_rule_path(backend_api)

    assert_select '#proxy_rule_redirect_url', false
  end
end
