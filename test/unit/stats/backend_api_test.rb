# frozen_string_literal: true

require 'test_helper'

class Stats::BackendApiTest < ActiveSupport::TestCase
  setup do
    provider = FactoryBot.create(:simple_provider)
    @backend_api = FactoryBot.create(:backend_api, account: provider)
    @services = FactoryBot.create_list(:simple_service, 3, account: provider)
    @services.each { |service| service.backend_api_configs.create(backend_api: backend_api, path: '/') }

    @storage = Stats::Base.storage
    storage.flushdb
    fake_storage_stats

    @client = Stats::BackendApi.new(@backend_api)
  end

  attr_reader :backend_api, :services, :storage, :client

  test '#usage gathers data from all products using the backend' do
    today = Time.utc(2020, 3, 19).to_date
    range = (today - 1.day)..today
    stats = client.usage(metric_name: backend_api.metrics.hits.system_name, since: range.begin, until: range.end, granularity: :day, timezone: ActiveSupport::TimeZone['UTC'].name)
    assert_equal 55, stats[:total]
    assert_same_elements [25, 30], stats[:values] # 2 days
  end

  test '#usage without skipping change' do
    date = Time.utc(2020, 3, 18).to_date
    stats = client.usage(metric_name: backend_api.metrics.hits.system_name, period: 'day', since: date, timezone: ActiveSupport::TimeZone['UTC'].name, skip_change: false)
    assert_equal 25, stats[:total]
    #                     00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23
    assert_same_elements [ 0, 5, 0, 0, 6, 0, 0, 0, 0, 0, 0, 4, 1, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0], stats[:values] # 24 hours
    assert_equal 10, stats[:previous_total]
    assert_equal 150.0, stats[:change]
  end

  test 'backend api without products' do
    backend_api.backend_api_configs.delete_all
    client = Stats::BackendApi.new(backend_api.reload)

    today = Time.utc(2020, 3, 19).to_date
    range = (today - 1.day)..today
    stats = client.usage(metric_name: backend_api.metrics.hits.system_name, since: range.begin, until: range.end, granularity: :day, timezone: ActiveSupport::TimeZone['UTC'].name)
    assert_equal 0, stats[:total]
    assert stats[:values].empty?
  end

  protected

  def fake_storage_stats
    # having different values of service 'hits' and backend 'hits' doesn't make much
    # sense if the services only use one backend, but that's OK because we are only
    # interested in backend 'hits' here.
    fake_service_stats(services[0], 'hour', '2020031701', service_hits: 10, backend_hits: 10)

    fake_service_stats(services[0], 'hour', '2020031801', service_hits:  5, backend_hits:  5)
    fake_service_stats(services[0], 'hour', '2020031804', service_hits: 10, backend_hits:  6)
    fake_service_stats(services[1], 'hour', '2020031811', service_hits:  3, backend_hits:  3)
    fake_service_stats(services[2], 'hour', '2020031811', service_hits:  1, backend_hits:  1)
    fake_service_stats(services[2], 'hour', '2020031812', service_hits:  1, backend_hits:  1)
    fake_service_stats(services[2], 'hour', '2020031815', service_hits: 13, backend_hits:  9)
    fake_service_stats(services[0], 'hour', '2020031922', service_hits: 29, backend_hits: 29)
    fake_service_stats(services[0], 'hour', '2020031923', service_hits:  1, backend_hits:  0)
    fake_service_stats(services[2], 'hour', '2020031906', service_hits:  1, backend_hits:  1)

    fake_service_stats(services[0], 'day', '20200318', service_hits: 15, backend_hits: 11)
    fake_service_stats(services[1], 'day', '20200318', service_hits:  3, backend_hits:  3)
    fake_service_stats(services[2], 'day', '20200318', service_hits: 15, backend_hits: 11)
    fake_service_stats(services[0], 'day', '20200319', service_hits: 30, backend_hits: 29)
    fake_service_stats(services[2], 'day', '20200319', service_hits:  1, backend_hits:  1)
  end

  def fake_service_stats(service, aggregation, time, service_hits:, backend_hits:)
    stats = { service.metrics.hits => service_hits, backend_api.metrics.hits => backend_hits }
    stats.each do |metric, hits|
      key = format 'stats/{service:%{service_id}}/metric:%{metric_id}/%{aggregation}:%{time}', {
        service_id: service.backend_id,
        metric_id: metric.id,
        aggregation: aggregation,
        time: time
      }
      storage.set(key, hits)
    end
  end
end
