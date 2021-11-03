# frozen_string_literal: true

require 'test_helper'

class Stats::Data::BaseControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @service = @provider.default_service
    @metric = service.metrics.hits
    @access_token = FactoryBot.create(:access_token, owner: provider.admin_users.first, scopes: ['stats'])

    host! @provider.self_domain
  end

  attr_reader :provider, :service, :metric, :access_token

  test 'required params' do
    url_params = { service_id: service.id, format: :json, access_token: access_token.value }
    stats_params = { metric_name: metric.system_name, period: 'day', timezone: ActiveSupport::TimeZone['UTC'].name, skip_change: false }

    get usage_stats_data_services_path(url_params), params: stats_params
    assert_response :success

    get usage_stats_data_services_path(url_params), params: stats_params.except(:metric_name)
    assert_response :bad_request
    assert_equal 'Required parameter missing: metric_name', response.body

    get usage_stats_data_services_path(url_params), params: stats_params.except(:period)
    assert_response :bad_request
    assert_equal 'Required parameter missing: granularity', response.body

    get usage_stats_data_services_path(url_params), params: stats_params.except(:period).merge(granularity: 'hour')
    assert_response :bad_request
    assert_equal 'Required parameter missing: since', response.body

    get usage_stats_data_services_path(url_params), params: stats_params.except(:period).merge(granularity: 'hour', since: '')
    assert_response :bad_request
    assert_equal 'Required parameter missing: since', response.body

    get usage_stats_data_services_path(url_params), params: stats_params.except(:period).merge(granularity: 'hour', since: Time.utc(2020, 3, 19).to_date, until: Time.utc(2020, 3, 21).to_date)
    assert_response :success

    # TODO: add a test for the undocumented use case: stats_params.except(:period).merge(granularity: 'hour', range: ?)
  end
end
