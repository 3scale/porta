# frozen_string_literal: true

require 'test_helper'

class Admin::Api::BackendApis::MetricsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:simple_provider)
    @backend_api = FactoryBot.create(:backend_api, account: provider)
    @metric = FactoryBot.create(:metric, owner: backend_api, service_id: nil) # the 2nd metric of the backend
    host! provider.external_admin_domain
  end

  attr_reader :provider, :backend_api, :metric

  class AdminPermission < self
    def setup
      super

      admin = FactoryBot.create(:admin, account: provider)
      @access_token = FactoryBot.create(:access_token, owner: admin, scopes: %w[account_management], permission: 'rw')
    end

    attr_reader :access_token
    delegate :value, to: :access_token, prefix: true

    test 'index' do
      FactoryBot.create(:metric, owner: backend_api, parent: backend_api.metrics.hits, service_id: nil) # a method metric
      FactoryBot.create(:metric, owner: FactoryBot.create(:backend_api, account: provider), service_id: nil) # other backend api
      FactoryBot.create(:metric, service: FactoryBot.create(:service, account: provider)) # owned by a service, not a backend api

      get admin_api_backend_api_metrics_path(backend_api), params: { access_token: access_token_value }

      assert_response :success
      assert(response_metrics = JSON.parse(response.body)['metrics'])
      assert_equal 3, response_metrics.length
      response_metric_ids = response_metrics.map { |metric| metric.dig('metric', 'id') }
      assert_same_elements backend_api.metrics.pluck(:id), response_metric_ids
    end

    test 'show' do
      get admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value }

      assert_response :success
      assert_equal metric.id, JSON.parse(response.body).dig('metric', 'id')
    end

    test 'create' do
      assert_difference(Metric.method(:count)) do
        post admin_api_backend_api_metrics_path(backend_api), params: { access_token: access_token_value, friendly_name: 'metric friendly name', unit: 'hit' }
        assert_response :created
      end
      metric = backend_api.metrics.find(JSON.parse(response.body).dig('metric', 'id'))
      assert_equal 'metric friendly name', metric.friendly_name
      assert_equal 'hit', metric.unit
      assert_equal "metric_friendly_name.#{backend_api.id}", metric.attributes['system_name']
    end

    test 'create with errors in the model' do
      post admin_api_backend_api_metrics_path(backend_api), params: { access_token: access_token_value, friendly_name: '', unit: 'hit' }
      assert_response :unprocessable_entity
      assert_contains JSON.parse(response.body).dig('errors', 'friendly_name'), 'can\'t be blank'
    end

    test 'update' do
      put admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value, friendly_name: 'metric friendly name', unit: 'hit' }
      assert_response :success
      metric.reload
      assert_equal 'metric friendly name', metric.friendly_name
      assert_equal 'hit', metric.unit
    end

    test 'cannot update system_name' do
      old_system_name = metric.system_name
      put admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value, system_name: 'new_system_name' }
      assert_response :success
      assert_equal old_system_name, metric.reload.system_name
    end

    test 'system_name can be created but not updated' do
      post admin_api_backend_api_metrics_path(backend_api), params: { access_token: access_token_value, friendly_name: 'metric friendly name', unit: 'hit', system_name: 'edited', system_name: 'first-system-name' }
      metric = backend_api.metrics.find(JSON.parse(response.body).dig('metric', 'id'))
      assert_equal "first-system-name.#{backend_api.id}", metric.attributes['system_name']

      put admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value, friendly_name: 'metric friendly name', unit: 'hit', system_name: 'edited' }
      assert_equal "first-system-name.#{backend_api.id}", metric.reload.attributes['system_name']
    end

    test 'update with errors in the model' do
      put admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value, friendly_name: '' }
      assert_response :unprocessable_entity
      assert_contains JSON.parse(response.body).dig('errors', 'friendly_name'), 'can\'t be blank'
    end

    test 'destroy' do
      metric = FactoryBot.create(:metric, owner: backend_api, service_id: nil)
      assert_difference(Metric.method(:count), -1) do
        delete admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value }
        assert_response :success
      end
      assert_raises(ActiveRecord::RecordNotFound) { metric.reload }
    end

    test 'index can be paginated' do
      FactoryBot.create_list(:metric, 5, owner: backend_api, service_id: nil)

      get admin_api_backend_api_metrics_path(backend_api), params: { access_token: access_token_value, per_page: 3, page: 2 }

      assert_response :success
      response_ids = JSON.parse(response.body)['metrics'].map { |response| response.dig('metric', 'id') }
      assert_equal backend_api.metrics.order(:id).offset(3).limit(3).select(:id).map(&:id), response_ids
    end

    test 'it cannot operate for metrics under a non-accessible backend api' do
      backend_api = FactoryBot.create(:backend_api, account: provider, state: :deleted)
      metric = FactoryBot.create(:metric, owner: backend_api, service_id: nil)

      get admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value }
      assert_response :not_found

      delete admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value }
      assert_response :not_found

      put admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value, friendly_name: 'metric friendly name', unit: 'hit' }
      assert_response :not_found

      post admin_api_backend_api_metrics_path(backend_api), params: { access_token: access_token_value, friendly_name: 'metric friendly name', unit: 'hit' }
      assert_response :not_found

      get admin_api_backend_api_metrics_path(backend_api), params: { access_token: access_token_value }
      assert_response :not_found
    end

    test 'when no params are sent, the error message is the same as in the other metrics endpoint' do
      post admin_api_backend_api_metrics_path(backend_api), params: { access_token: access_token_value }
      assert_response :unprocessable_entity
      assert_contains JSON.parse(response.body).dig('errors', 'friendly_name'), 'can\'t be blank'
      assert_contains JSON.parse(response.body).dig('errors', 'unit'), 'can\'t be blank'

      put admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value }
      assert_response :success
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

      get admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value }
      assert_response :success

      put admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value, friendly_name: 'metric friendly name', unit: 'hit' }
      assert_response :success

      delete admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value }
      assert_response :success

      post admin_api_backend_api_metrics_path(backend_api), params: { access_token: access_token_value, friendly_name: 'metric friendly name', unit: 'hit' }
      assert_response :success

      get admin_api_backend_api_metrics_path(backend_api), params: { access_token: access_token_value }
      assert_response :success
    end

    test 'member without permission' do
      get admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value }
      assert_response :forbidden

      put admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value, friendly_name: 'metric friendly name', unit: 'hit' }
      assert_response :forbidden

      delete admin_api_backend_api_metric_path(backend_api, metric), params: { access_token: access_token_value }
      assert_response :forbidden

      post admin_api_backend_api_metrics_path(backend_api), params: { access_token: access_token_value, friendly_name: 'metric friendly name', unit: 'hit' }
      assert_response :forbidden

      get admin_api_backend_api_metrics_path(backend_api), params: { access_token: access_token_value }
      assert_response :forbidden
    end
  end
end
