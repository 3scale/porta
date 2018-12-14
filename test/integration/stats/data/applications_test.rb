require 'test_helper'

class Stats::Data::ApplicationsTest < ActionDispatch::IntegrationTest
  def setup
    @cinstance = FactoryGirl.create(:cinstance)
    login! @cinstance.provider_account
  end

  test 'usage_response_code with no data as json' do
    get "/stats/applications/#{@cinstance.id}/usage_response_code.json",
      period: 'day', response_code: 200, timezone: 'Madrid', skip_change: false

    assert_response :success
    assert_content_type 'application/json'

    response = ActiveSupport::JSON.decode(@response.body)
    response["values"] == [0] * 25
    response["change"] == 0.0
  end

  test 'summary returns the metrics and methods with its visibility value for the plan' do
    service = @cinstance.service
    hits_metric = service.metrics.find_by(system_name: 'hits')
    FactoryGirl.create_list(:metric, 2, service: service, parent: hits_metric)
    FactoryGirl.create(:plan_metric, visible: false, metric: service.method_metrics.last!, plan: @cinstance.plan)
    FactoryGirl.create_list(:metric, 2, service: service, parent: nil)
    FactoryGirl.create(:plan_metric, visible: false, metric: service.metrics.top_level.last!, plan: @cinstance.plan)

    get summary_stats_data_applications_path(@cinstance, format: :json)
    json_response = JSON.parse(response.body)

    top_level_metrics_response = (json_response['metrics'] || [])
    method_metrics_response = (json_response['methods'] || [])

    expected_metrics = service.metrics.top_level
    expected_methods = service.method_metrics

    assert_same_elements expected_metrics.pluck(:id), top_level_metrics_response.map { |metric_response| metric_response.dig('metric', 'id') }
    assert_same_elements expected_methods.pluck(:id), method_metrics_response.map { |metric_response| metric_response.dig('metric', 'id') }

    top_level_metrics_response.each do |metric_response|
      metric = Metric.find metric_response.dig('metric', 'id')
      assert_equal metric.visible_in_plan?(@cinstance.plan), metric_response.dig('metric', 'visible')
    end
    method_metrics_response.each do |metric_response|
      metric = Metric.find metric_response.dig('metric', 'id')
      assert_equal metric.visible_in_plan?(@cinstance.plan), metric_response.dig('metric', 'visible')
    end
  end
end
