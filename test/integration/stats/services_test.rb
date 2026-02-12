# frozen_string_literal: true

require 'test_helper'

class Stats::ServicesTest < ActionDispatch::IntegrationTest
  def setup
    Stats::Base.storage.flushdb
    @provider_account = FactoryBot.create(:provider_account)
    @service = @provider_account.default_service
    @metric = @service.metrics.hits!
    Stats::Base.storage.flushdb

    host! @provider_account.internal_admin_domain
    provider_login_with @provider_account.admins.first.username, 'superSecret1234#'
  end

  test 'usage_response_code with no data as json' do
    travel_to(Time.utc(2009, 12, 4, 11, 12))
    plan = FactoryBot.create(:application_plan, issuer: @provider_account.default_service)
    @cinstance = FactoryBot.create(:cinstance, plan: plan)

    get usage_response_code_stats_api_services_path(@cinstance.service_id, format: :json), params: { period: 'day', response_code: 200, timezone: 'Madrid', skip_change: false }

    assert_response :success
    assert_media_type 'application/json'

    assert_json "period" => { "name" => "day",
                              "granularity" => "hour",
                              "since" => Time.zone.parse("2009-12-03T12:00:00+01:00"),
                              "until" => Time.zone.parse("2009-12-04T12:59:59+01:00"),
                              "timezone" => "Europe/Madrid" },
                "total" => 0,
                "values" => [0] * 25,
                "previous_total" => 0,
                "change" =>0.0,
                "response_code" => { 'code' => '200' }
  end

  test 'usage with no data as json' do
    travel_to(Time.utc(2009, 12, 4, 11, 12))
    plan = FactoryBot.create(:application_plan, issuer: @provider_account.default_service)
    @cinstance = FactoryBot.create(:cinstance, plan: plan)

    get usage_stats_api_services_path(@cinstance.service_id, format: :json), params: { period: 'day', metric_name: @metric.system_name, timezone: 'Madrid', skip_change: false }

    assert_response :success
    assert_media_type 'application/json'

    assert_json "period" => { "name" => "day",
                              "granularity" => "hour",
                              "since" => Time.zone.parse("2009-12-03T12:00:00+01:00"),
                              "until" => Time.zone.parse("2009-12-04T12:59:59+01:00"),
                              "timezone" => "Europe/Madrid" },
                "total" => 0,
                "values" => [0] * 25,
                "previous_total" => 0,
                "change" =>0.0,
                "metric" => { "name" => @metric.friendly_name,
                               "id" => @metric.id,
                               "unit" => @metric.unit,
                               "system_name" => @metric.system_name }


  end

  test 'with simple plan and cinstance, retrieve data with account timezone' do
    travel_to(Time.utc(2009, 12, 11, 19, 10))
    plan = FactoryBot.create(:application_plan, issuer: @service)
    @cinstance = FactoryBot.create(:cinstance, plan: plan)
    @provider_account.update(timezone: 'Madrid')

    opts = { period: 'day', metric_name: @metric.system_name }
    get usage_stats_api_services_path(@cinstance.service_id, format: :json), params: opts

    assert_response :success
    assert_media_type 'application/json'

    assert_json_contains "period" => { "name" => "day",
                                       "granularity" => "hour",
                                       "since" => Time.zone.parse("2009-12-10T20:00:00+01:00"),
                                       "until" => Time.zone.parse("2009-12-11T20:59:59+01:00"),
                                       "timezone" => "Europe/Madrid" }
  end

  test 'with simple plan and cinstance, retrieve data with specified timezone' do
    travel_to(Time.utc(2009, 12, 11, 19, 10))
    plan = FactoryBot.create(:application_plan, issuer: @service)
    @cinstance = FactoryBot.create(:cinstance, plan: plan)

    opts = { period: 'day', metric_name: @metric.system_name, timezone: 'Kamchatka' }
    get usage_stats_api_services_path(@cinstance.service_id, format: :json), params: opts

    assert_response :success
    assert_media_type 'application/json'
    assert_json_contains "period" => { "name" => "day",
                                       "granularity" => "hour",
                                       "since" => Time.zone.parse("2009-12-11T07:00:00+12:00"),
                                       "until" => Time.zone.parse("2009-12-12T07:59:59+12:00"),
                                       "timezone" => "Asia/Kamchatka" }
  end

  test 'usage with some data as json' do
    plan = FactoryBot.create(:application_plan, issuer: @service)
    cinstance = FactoryBot.create(:cinstance, plan: plan)

    # This one is outside of the time range
    make_transaction_at(Time.utc(2009, 12, 11, 10, 35), cinstance_id: cinstance.id)

    # These are in
    make_transaction_at(Time.utc(2009, 12, 11, 18, 20), cinstance_id: cinstance.id)
    make_transaction_at(Time.utc(2009, 12, 11, 18, 21), cinstance_id: cinstance.id)
    make_transaction_at(Time.utc(2009, 12, 11, 18, 45), cinstance_id: cinstance.id)

    travel_to(Time.utc(2009, 12, 11, 19, 10))
    get usage_stats_api_services_path(@provider_account.default_service, format: :json), params: { period: 'day', metric_name: @metric.system_name, timezone: 'UTC', skip_change: false }

    assert_response :success
    assert_media_type 'application/json'

    assert_json "period" => { "name" => "day",
                              "granularity" => "hour",
                              "since" => Time.zone.parse("2009-12-10T19:00:00Z"),
                              "until" => Time.zone.parse("2009-12-11T19:59:59Z"),
                              "timezone" => "Etc/UTC" },
                "total" => 4,
                "previous_total" => 0,
                "change" => 100.0,
                "values" => [0] * 15 + [1] + [0] * 7 + [3] + [0],
                "metric" => { "name" => @metric.friendly_name,
                              "id" => @metric.id,
                              "unit" => @metric.unit,
                              "system_name" => @metric.system_name }

  end

  test 'positive timezone shifting' do
    plan = FactoryBot.create(:application_plan, issuer: @service)
    cinstance = FactoryBot.create(:cinstance, plan: plan)

    # This one is outside of the time range
    make_transaction_at(Time.utc(2009, 12, 31, 10, 35), cinstance_id: cinstance.id)

    # This is in
    make_transaction_at(Time.utc(2009, 12, 31, 23, 20), cinstance_id: cinstance.id)
    make_transaction_at(Time.utc(2010, 1, 1, 12, 21), cinstance_id: cinstance.id)
    make_transaction_at(Time.utc(2010, 12, 1, 12, 21), cinstance_id: cinstance.id)

    # This is out
    make_transaction_at(Time.utc(2011, 1, 1, 23, 21), cinstance_id: cinstance.id)

    get usage_stats_api_services_path(@provider_account.default_service, format: :json), params: { period: 'year', metric_name: @metric.system_name, timezone: 'Madrid', since: "2010-01-01", skip_change: false }

    assert_response :success
    assert_media_type 'application/json'

    assert_json "period" => { "name" => "year",
                              "granularity" => "month",
                              "since" => Time.zone.parse("2010-01-01T00:00:00+01:00"),
                              "until" => Time.zone.parse("2010-12-31T23:59:59+01:00"),
                              "timezone" => "Europe/Madrid" },
                "total" => 3,
                "previous_total" => 1,
                "change" => 200.0,
                "values" => [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                "metric" => { "name" => @metric.friendly_name,
                              "id" => @metric.id,
                              "unit" => @metric.unit,
                              "system_name" => @metric.system_name }
  end

  test 'negative timezone shifting' do
    plan = FactoryBot.create(:application_plan, issuer: @service)
    cinstance = FactoryBot.create(:cinstance, plan: plan)

    # This one is outside of the time range
    make_transaction_at(Time.utc(2010, 1, 1, 0, 35), cinstance_id: cinstance.id)

    # This is in
    make_transaction_at(Time.utc(2010, 1, 1, 1, 20), cinstance_id: cinstance.id)
    make_transaction_at(Time.utc(2010, 1, 1, 23, 55), cinstance_id: cinstance.id)
    make_transaction_at(Time.utc(2011, 1, 1, 0, 21), cinstance_id: cinstance.id)

    # This is out
    make_transaction_at(Time.utc(2011, 1, 1, 1, 21), cinstance_id: cinstance.id)

    get usage_stats_api_services_path(@provider_account.default_service, format: :json), params: { period: 'year', metric_name: @metric.system_name, timezone: 'Azores', since: "2010-01-01", skip_change: false }

    assert_response :success
    assert_media_type 'application/json'

    assert_json "period" => { "name" => "year",
                              "granularity" => "month",
                              "since" => Time.zone.parse("2010-01-01T00:00:00-01:00"),
                              "until" => Time.zone.parse("2010-12-31T23:59:59-01:00"),
                              "timezone" => "Atlantic/Azores" },
                "total" => 3,
                "previous_total" => 1,
                "change" => 200.0,
                "values" => [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
                "metric" => { "name" => @metric.friendly_name,
                              "id" => @metric.id,
                              "unit" => @metric.unit,
                              "system_name" => @metric.system_name }
  end

  test 'top_clients as json' do
    plan = FactoryBot.create(:application_plan, issuer: @service)
    cinstance1 = FactoryBot.create(:cinstance, plan: plan)
    cinstance2 = FactoryBot.create(:cinstance, plan: plan)

    make_transaction_at(Time.utc(2009, 12,  2), cinstance_id: cinstance1.id)
    make_transaction_at(Time.utc(2009, 12,  3), cinstance_id: cinstance2.id)
    make_transaction_at(Time.utc(2009, 12, 15), cinstance_id: cinstance1.id)

    travel_to(Time.utc(2009, 12, 22))
    get top_applications_stats_api_services_path(@provider_account.default_service, format: :json), params: { period: :month, metric_name: @metric.system_name }

    assert_response :success
    assert_media_type 'application/json'
    assert_json "period" => { "name" => "month", "since" => "2009-12-01T00:00:00Z", "until" => "2009-12-31T23:59:59Z" },
                "applications" => [{ "name" => cinstance1.name,
                                     "plan" => { "name" => plan.name, "id" => plan.id },
                                     "id" => cinstance1.id,
                                     "value" => "2",
                                     "account" => { "name" => cinstance1.user_account.org_name, "id" => cinstance1.user_account.id },
                                     "service" => { "id" => cinstance1.service_id } },
                                   { "name" => cinstance2.name,
                                     "plan" => { "name" => plan.name, "id" => plan.id },
                                     "id" => cinstance2.id,
                                     "value" => "1",
                                     "account" => { "name" => cinstance2.user_account.org_name, "id" => cinstance2.user_account.id },
                                     "service" => { "id" => cinstance2.service_id } }],
                "metric" => { "name" => @metric.friendly_name, "id" => @metric.id, "unit" => @metric.unit, "system_name" => @metric.system_name }
  end
end
