# frozen_string_literal: true

require 'test_helper'

class Admin::Api::BackendApis::MappingRulesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:simple_provider)
    @backend_api = FactoryBot.create(:backend_api, account: provider)
    @mapping_rule = FactoryBot.create(:proxy_rule, owner: backend_api, proxy: nil)
    host! provider.external_admin_domain
  end

  attr_reader :provider, :backend_api, :mapping_rule

  class AdminPermission < self
    def setup
      super

      admin = FactoryBot.create(:admin, account: provider)
      @access_token = FactoryBot.create(:access_token, owner: admin, scopes: %w[account_management], permission: 'rw')
    end

    attr_reader :access_token
    delegate :value, to: :access_token, prefix: true

    test 'index' do
      FactoryBot.create_list(:proxy_rule, 2, owner: backend_api, proxy: nil) # two more of the same backend api
      FactoryBot.create(:proxy_rule, owner: FactoryBot.create(:backend_api, account: provider), proxy: nil) # other backend api
      FactoryBot.create(:proxy_rule, proxy: FactoryBot.create(:simple_service, account: provider).proxy) # owned by a proxy, not a backend api

      get admin_api_backend_api_mapping_rules_path(backend_api), params: { access_token: access_token_value }

      assert_response :success
      assert(response_mapping_rules = JSON.parse(response.body)['mapping_rules'])
      assert_equal 3, response_mapping_rules.length
      response_mapping_rule_ids = response_mapping_rules.map { |mapping_rule| mapping_rule.dig('mapping_rule', 'id') }
      assert_same_elements backend_api.mapping_rules.pluck(:id), response_mapping_rule_ids
    end

    test 'show' do
      get admin_api_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { access_token: access_token_value }

      assert_response :success
      assert_equal mapping_rule.id, JSON.parse(response.body).dig('mapping_rule', 'id')
    end

    test 'create' do
      assert_difference(ProxyRule.method(:count)) do
        post admin_api_backend_api_mapping_rules_path(backend_api), params: { access_token: access_token_value, **mapping_rule_params }
        assert_response :created
      end

      mapping_rule = backend_api.mapping_rules.find(JSON.parse(response.body).dig('mapping_rule', 'id'))
      mapping_rule_params.each do |field_name, expected_value|
        assert_equal expected_value, mapping_rule.public_send(field_name)
      end
    end

    test 'create without metric_id gives an error' do
      assert_no_difference(ProxyRule.method(:count)) do
        post admin_api_backend_api_mapping_rules_path(backend_api), params: { access_token: access_token_value, **mapping_rule_params.except(:metric_id) }
        assert_response :unprocessable_entity
        assert_contains JSON.parse(response.body).dig('errors', 'metric_id'), 'can\'t be blank'
      end
    end

    test 'update' do
      put admin_api_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { access_token: access_token_value, **mapping_rule_params }
      assert_response :success
      mapping_rule.reload
      mapping_rule_params.each do |field_name, expected_value|
        assert_equal expected_value, mapping_rule.public_send(field_name)
      end
    end

    test 'update with errors in the model' do
      put admin_api_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { access_token: access_token_value, http_method: 'invalid' }
      assert_response :unprocessable_entity
      assert_contains JSON.parse(response.body).dig('errors', 'http_method'), 'is not included in the list'
    end

    test 'destroy' do
      delete admin_api_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { access_token: access_token_value }
      assert_response :success
      assert_raises(ActiveRecord::RecordNotFound) { mapping_rule.reload }
    end

    test 'index can be paginated' do
      FactoryBot.create_list(:proxy_rule, 5, owner: backend_api, proxy_id: nil)

      get admin_api_backend_api_mapping_rules_path(backend_api), params: { access_token: access_token_value, per_page: 3, page: 2 }

      assert_response :success
      response_ids = JSON.parse(response.body)['mapping_rules'].map { |response| response.dig('mapping_rule', 'id') }
      assert_equal backend_api.mapping_rules.order(:id).offset(3).limit(3).select(:id).map(&:id), response_ids
    end

    test 'it cannot operate under a non-accessible backend api' do
      backend_api = FactoryBot.create(:backend_api, account: provider, state: :deleted)
      mapping_rule = FactoryBot.create(:proxy_rule, owner: backend_api, proxy: nil)

      get admin_api_backend_api_mapping_rules_path(backend_api), params: { access_token: access_token_value }
      assert_response :not_found

      get admin_api_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { access_token: access_token_value }
      assert_response :not_found

      post admin_api_backend_api_mapping_rules_path(backend_api), params: { access_token: access_token_value, **mapping_rule_params }
      assert_response :not_found

      put admin_api_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { access_token: access_token_value, **mapping_rule_params }
      assert_response :not_found

      delete admin_api_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { access_token: access_token_value }
      assert_response :not_found
    end
  end

  class MemberPermission < self
    def setup
      super

      @member = FactoryBot.create(:member, account: provider)
      @access_token = FactoryBot.create(:access_token, owner: member, scopes: %w[account_management], permission: 'rw')
      member.activate!
    end

    attr_reader :member, :access_token
    delegate :value, to: :access_token, prefix: true

    test 'member with permission' do
      member.admin_sections = %w[partners plans]
      member.save!

      get admin_api_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { access_token: access_token_value }
      assert_response :success

      put admin_api_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { access_token: access_token_value, **mapping_rule_params }
      assert_response :success

      delete admin_api_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { access_token: access_token_value }
      assert_response :success

      post admin_api_backend_api_mapping_rules_path(backend_api), params: { access_token: access_token_value, **mapping_rule_params }
      assert_response :success

      get admin_api_backend_api_mapping_rules_path(backend_api), params: { access_token: access_token_value }
      assert_response :success
    end

    test 'member without permission' do
      get admin_api_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { access_token: access_token_value }
      assert_response :forbidden

      put admin_api_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { access_token: access_token_value, **mapping_rule_params }
      assert_response :forbidden

      delete admin_api_backend_api_mapping_rule_path(backend_api, mapping_rule), params: { access_token: access_token_value }
      assert_response :forbidden

      post admin_api_backend_api_mapping_rules_path(backend_api), params: { access_token: access_token_value, **mapping_rule_params }
      assert_response :forbidden

      get admin_api_backend_api_mapping_rules_path(backend_api), params: { access_token: access_token_value }
      assert_response :forbidden
    end
  end

  protected

  def mapping_rule_params
    @mapping_rule_params ||= { http_method: 'POST', pattern: '/mypattern', delta: 3, last: true, position: 2, metric_id: backend_api.metrics.hits.id }
  end
end
