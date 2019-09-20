# frozen_string_literal: true

require 'test_helper'

class Admin::API::BackendApis::MappingRulesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @tenant = FactoryBot.create(:provider_account)
    host! @tenant.admin_domain
    @access_token_value = FactoryBot.create(:access_token, owner: @tenant.admin_users.first!, scopes: %w[account_management], permission: 'rw').value
    @backend_api = FactoryBot.create(:backend_api, account: @tenant)
  end

  attr_reader :backend_api, :access_token_value, :tenant

  test 'index' do
    FactoryBot.create_list(:proxy_rule, 2, owner: backend_api, proxy: nil)
    FactoryBot.create(:proxy_rule, owner: FactoryBot.create(:backend_api, account: tenant), proxy: nil)
    FactoryBot.create(:proxy_rule, proxy: tenant.default_service.proxy)

    get admin_api_backend_api_mapping_rules_path(backend_api_id: backend_api.id, access_token: access_token_value)

    assert_response :success
    assert(response_collection_mapping_rules_of_backend_api = JSON.parse(response.body)['mapping_rules'])
    assert_equal 2, response_collection_mapping_rules_of_backend_api.length
    response_collection_mapping_rules_of_backend_api.each do |response_mapping_rule|
      assert backend_api.mapping_rules.find_by(id: response_mapping_rule.dig('mapping_rule', 'id'))
    end
  end

  test 'show' do
    get admin_api_backend_api_mapping_rule_path(backend_api_id: backend_api.id, access_token: access_token_value, id: mapping_rule.id)

    assert_response :success
    assert_equal mapping_rule.id, JSON.parse(response.body).dig('mapping_rule', 'id')
  end

  test 'create' do
    assert_difference(ProxyRule.method(:count)) do
      post admin_api_backend_api_mapping_rules_path(backend_api_id: backend_api.id, access_token: access_token_value), mapping_rule_params
      assert_response :created
    end
    assert(@mapping_rule = backend_api.mapping_rules.find_by(id: JSON.parse(response.body).dig('mapping_rule', 'id')))
    mapping_rule_params.each do |field_name, expected_value|
      assert_equal expected_value, mapping_rule.public_send(field_name)
    end
  end

  test 'create without metric_id gives an error' do
    assert_no_difference(ProxyRule.method(:count)) do
      post admin_api_backend_api_mapping_rules_path(backend_api_id: backend_api.id, access_token: access_token_value), mapping_rule_params.except(:metric_id)
      assert_response :unprocessable_entity
      assert_contains JSON.parse(response.body).dig('errors', 'metric_id'), 'can\'t be blank'
    end
  end

  test 'update' do
    put admin_api_backend_api_mapping_rule_path(backend_api_id: backend_api.id, access_token: access_token_value, id: mapping_rule.id), mapping_rule_params
    assert_response :success
    mapping_rule.reload
    mapping_rule_params.each do |field_name, expected_value|
      assert_equal expected_value, mapping_rule.public_send(field_name)
    end
  end

  test 'update with errors in the model' do
    put admin_api_backend_api_mapping_rule_path(backend_api_id: backend_api.id, access_token: access_token_value, id: mapping_rule.id), { http_method: 'invalid' }
    assert_response :unprocessable_entity
    assert_contains JSON.parse(response.body).dig('errors', 'http_method'), 'is not included in the list'
  end

  test 'destroy' do
    delete admin_api_backend_api_mapping_rule_path(backend_api_id: backend_api.id, access_token: access_token_value, id: mapping_rule.id)
    assert_response :success
    assert_raises(ActiveRecord::RecordNotFound) { mapping_rule.reload }
  end

  private

  def mapping_rule
    @mapping_rule ||= FactoryBot.create(:proxy_rule, owner: backend_api, proxy: nil)
  end

  def mapping_rule_params
    @mapping_rule_params ||= { http_method: 'POST', pattern: '/mypattern', delta: 3, last: true, position: 2, metric_id: backend_api.metrics.hits.id }
  end
end
