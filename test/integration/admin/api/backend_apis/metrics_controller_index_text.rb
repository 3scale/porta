# frozen_string_literal: true

require 'test_helper'

class Admin::Api::BackendApis::MetricsControllerIndexTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:simple_provider)
    admin = FactoryBot.create(:admin, account: provider)
    @token = FactoryBot.create(:access_token, owner: admin, scopes: %w[account_management], permission: 'rw')

    host! provider.admin_domain
  end

  attr_reader :provider, :token

  test 'index' do
    backend_api = FactoryBot.create(:backend_api, account: provider)
    other_backend_api = FactoryBot.create(:backend_api, account: provider)

    FactoryBot.create(:metric, owner: backend_api, parent: backend_api.metrics.hits, service_id: nil) # a method metric
    FactoryBot.create(:metric, owner: other_backend_api, service_id: nil)
    FactoryBot.create(:metric, service: FactoryBot.create(:service, account: provider))

    get admin_api_backend_api_metrics_path(backend_api), params: { access_token: token.value }
    assert_response :success

    response_metrics = JSON.parse(response.body)['metrics']

    assert_equal 2, response_metrics.length
    response_metric_ids = response_metrics.map { |metric| metric.dig('metric', 'id') }
    assert_same_elements backend_api.metrics.pluck(:id), response_metric_ids
  end

  test 'index can be paginated' do
    backend_api = FactoryBot.create(:backend_api, account: provider)
    FactoryBot.create_list(:metric, 5, owner: backend_api, service_id: nil)

    get admin_api_backend_api_metrics_path(backend_api), params: { access_token: token.value, per_page: 3, page: 2 }
    assert_response :success

    response_ids = JSON.parse(response.body)['metrics'].map { |response| response.dig('metric', 'id') }
    assert_equal 3, response_ids.length
    assert_equal backend_api.metrics.order(:id).offset(3).limit(3).select(:id).map(&:id), response_ids
  end
end
