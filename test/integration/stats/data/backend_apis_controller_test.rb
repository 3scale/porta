# frozen_string_literal: true

require 'test_helper'

class Stats::Data::BackendApisControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @backend_api = @provider.default_service.backend_apis.first
    @metric = backend_api.metrics.hits
    @access_token  = FactoryBot.create(:access_token, owner: provider.admin_users.first, scopes: ['stats'])

    host! @provider.self_domain
  end

  attr_reader :provider, :backend_api, :metric, :access_token

  test 'usage_response_code with no data as json' do
    get usage_stats_data_backend_apis_path(backend_api_id: backend_api.id, format: :json, access_token: access_token.value), params: stats_params

    assert_response :success
    assert_content_type 'application/json'

    expected_response = {
      metric: metric.attributes.slice(*%w[id system_name unit]).merge(name: metric.friendly_name),
      period: { name: 'day', since: '2020-03-19T00:00:00Z', until: '2020-03-19T23:59:59Z', timezone: 'Etc/UTC', granularity: 'hour' },
      total: 0,
      values: [0] * 24,
      previous_total: 0,
      change: 0.0
    }.deep_stringify_keys

    assert_equal expected_response, JSON.parse(response.body)
  end

  test 'inexistent source' do
    get usage_stats_data_backend_apis_path(backend_api_id: 0, format: :json, access_token: access_token.value), params: stats_params
    assert_response :not_found
  end

  test 'user permissions' do
    member_user = FactoryBot.create(:member, account: provider)
    member_access_token  = FactoryBot.create(:access_token, owner: member_user, scopes: ['stats'])
    get usage_stats_data_backend_apis_path(backend_api_id: backend_api.id, format: :json, access_token: member_access_token.value), params: stats_params
    assert_response :forbidden

    get usage_stats_data_backend_apis_path(backend_api_id: backend_api.id, format: :json, access_token: access_token.value), params: stats_params
    assert_response :success
  end

  protected

  def stats_params
    { metric_name: metric.system_name, period: 'day', since: Time.utc(2020, 3, 19).to_date, timezone: ActiveSupport::TimeZone['UTC'].name, skip_change: false }
  end
end
