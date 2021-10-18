# frozen_string_literal: true

require 'test_helper'

class Stats::ClientsTest < ActionDispatch::IntegrationTest
  def setup
    @provider_account = FactoryBot.create(:provider_account)
    @service = @provider_account.default_service
    @metric = @service.metrics.hits!

    plan = FactoryBot.create(:application_plan, :issuer => @service)
    @cinstance = FactoryBot.create(:cinstance, :plan => plan)

    Stats::Base.storage.flushdb
  end

  def teardown
    Timecop.return
  end

  test 'usage with invalid period' do
    login! @provider_account
    get "/stats/api/applications/#{@cinstance.id}/usage.json", params: { :period => 'XSScript', :metric_name => @metric.system_name }
    assert_response :bad_request
  end

  test 'usage as json' do
    # This one is outside of the time range
    make_transaction_at(Time.utc(2009, 11,  3), :cinstance_id => @cinstance.id)

    # These are in
    make_transaction_at(Time.utc(2009, 12,  4, 11, 30), :cinstance_id => @cinstance.id)
    make_transaction_at(Time.utc(2009, 12,  4, 22, 15), :cinstance_id => @cinstance.id)
    make_transaction_at(Time.utc(2009, 12, 12), :cinstance_id => @cinstance.id)

    Timecop.freeze(Time.utc(2009, 12, 13))

    login! @provider_account
    @provider_account.update_attribute(:timezone, 'Madrid')

    get "/stats/api/applications/#{@cinstance.id}/usage.json", params: { period:'month', metric_name: @metric.system_name, skip_change: false }

    assert_response :success
    assert_content_type 'application/json'
    assert_json "period"=>
      {"name"=>"month",
       "granularity"=>"day",
       "since"=>Time.parse("2009-11-13T00:00:00+01:00"),
       "until"=>Time.parse("2009-12-13T23:59:59+01:00"),
       "timezone"=>"Europe/Madrid"},
     "total"=>3,
     "application"=>
      {"name"=>@cinstance.name,
       "plan"=>{"name"=>@cinstance.plan.name, "id"=>@cinstance.plan.id},
       "id"=>@cinstance.id,
       "account"=>{"name"=>@cinstance.user_account.org_name, "id"=>@cinstance.user_account.id},
       "description"=>@cinstance.description,
       "state"=>@cinstance.state,
       "service"=>{"id"=>@cinstance.service_id}},
     "values"=> [0] * 21 + [2] + [0] * 7 + [1, 0],
     "previous_total" => 1,
     "change"=>200.0,
     "metric"=>{"name"=>@metric.friendly_name, "id"=>@metric.id, "unit"=>@metric.unit, "system_name"=>@metric.system_name}
  end

  test 'usage_response_code as json' do
    # This one is outside of the time range
    make_transaction_at(Time.utc(2009, 11,  3), :cinstance_id => @cinstance.id)

    # These are in
    make_transaction_at(Time.utc(2009, 12,  4, 11, 30), :cinstance_id => @cinstance.id)
    make_transaction_at(Time.utc(2009, 12,  4, 22, 15), :cinstance_id => @cinstance.id)
    make_transaction_at(Time.utc(2009, 12, 12), :cinstance_id => @cinstance.id)
    make_transaction_at(Time.utc(2009, 12, 12), :cinstance_id => @cinstance.id, :log => { 'code' => 404 } )

    Timecop.freeze(Time.utc(2009, 12, 13))

    login! @provider_account
    @provider_account.update_attribute(:timezone, 'Madrid')

    get "/stats/api/applications/#{@cinstance.id}/usage_response_code.json", params: { period:'month', response_code: 200 }

    assert_response :success
    assert_content_type 'application/json'
    assert_json "response_code" => {'code' => '200'},
    "period"=>
      {"name"=>"month",
       "granularity"=>"day",
       "since"=>Time.parse("2009-11-13T00:00:00+01:00"),
       "until"=>Time.parse("2009-12-13T23:59:59+01:00"),
       "timezone"=>"Europe/Madrid"},
     "total"=>3,
     "application"=>
      {"name"=>@cinstance.name,
       "plan"=>{"name"=>@cinstance.plan.name, "id"=>@cinstance.plan.id},
       "id"=>@cinstance.id,
       "account"=>{"name"=>@cinstance.user_account.org_name, "id"=>@cinstance.user_account.id},
       "description"=>@cinstance.description,
       "state"=>@cinstance.state,
       "service"=>{"id"=>@cinstance.service_id}},
     "values"=> [0] * 21 + [2] + [0] * 7 + [1, 0]

    get "/stats/api/applications/#{@cinstance.id}/usage_response_code.json", params: { period:'month', response_code: 404 }

    assert_response :success
    assert_content_type 'application/json'
    assert_json "response_code" => {'code' => '404'},
    "period"=>
      {"name"=>"month",
       "granularity"=>"day",
       "since"=>Time.parse("2009-11-13T00:00:00+01:00"),
       "until"=>Time.parse("2009-12-13T23:59:59+01:00"),
       "timezone"=>"Europe/Madrid"},
     "total"=>1,
     "application"=>
      {"name"=>@cinstance.name,
       "plan"=>{"name"=>@cinstance.plan.name, "id"=>@cinstance.plan.id},
       "id"=>@cinstance.id,
       "account"=>{"name"=>@cinstance.user_account.org_name, "id"=>@cinstance.user_account.id},
       "description"=>@cinstance.description,
       "state"=>@cinstance.state,
       "service"=>{"id"=>@cinstance.service_id}},
     "values"=> [0] * 29 + [1, 0]
  end
end
