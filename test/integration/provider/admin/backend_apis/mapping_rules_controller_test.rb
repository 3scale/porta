# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::BackendApis::MappingRulesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    @backend_api = @provider.first_service.backend_api

    FactoryBot.create(:proxy_rule, proxy: nil, owner: @backend_api)

    login_provider @provider
  end

  attr_reader :provider, :backend_api

  test '#index' do
    get provider_admin_backend_api_mapping_rules_path(backend_api)

    assert_response :success
    assert_select 'table tbody tr', count: @backend_api.mapping_rules.count
    @backend_api.mapping_rules.each { |rule| assert_select 'table tr td', text: rule.pattern }
  end

  test 'it cannot operate under non-accessible backend api' do
    backend_api = FactoryBot.create(:backend_api, account: @provider, state: :deleted)

    get provider_admin_backend_api_mapping_rules_path(backend_api)
    assert_response :not_found

    post provider_admin_backend_api_mapping_rules_path(backend_api), params: {}
    assert_response :not_found

    get new_provider_admin_backend_api_mapping_rule_path(backend_api)
    assert_response :not_found

    get edit_provider_admin_backend_api_mapping_rule_path(backend_api, @backend_api.mapping_rules.first)
    assert_response :not_found

    put provider_admin_backend_api_mapping_rule_path(backend_api, @backend_api.mapping_rules.first), params: {}
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

  test 'member permissions' do
    member = FactoryBot.create(:member, account: provider)
    member.activate!

    logout! && login!(provider, user: member)

    get provider_admin_backend_api_mapping_rules_path(backend_api)
    assert_response :forbidden

    get new_provider_admin_backend_api_mapping_rule_path(backend_api)
    assert_response :forbidden

    mapping_rule = backend_api.mapping_rules.first
    mapping_rule_params = {
      http_method: 'GET',
      pattern: '/foo',
      delta: '1',
      metric_id: mapping_rule.metric_id.to_s,
      position: '2',
      last: '0'
    }
    post provider_admin_backend_api_mapping_rules_path(backend_api), params: { proxy_rule: mapping_rule_params }
    assert_response :forbidden

    get edit_provider_admin_backend_api_mapping_rule_path(backend_api, mapping_rule)
    assert_response :forbidden

    put provider_admin_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { proxy_rule: mapping_rule_params }
    assert_response :forbidden

    member.admin_sections = %w[plans]
    member.save!

    get provider_admin_backend_api_mapping_rules_path(backend_api)
    assert_response :success

    get new_provider_admin_backend_api_mapping_rule_path(backend_api)
    assert_response :success

    post provider_admin_backend_api_mapping_rules_path(backend_api), params: { proxy_rule: mapping_rule_params }
    assert_response :redirect

    get edit_provider_admin_backend_api_mapping_rule_path(backend_api, mapping_rule)
    assert_response :success

    put provider_admin_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { proxy_rule: mapping_rule_params }
    assert_response :redirect
  end
end
