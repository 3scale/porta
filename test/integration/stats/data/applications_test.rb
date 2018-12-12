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

  test 'summary returns the visible metrics and methods' do
    service = @cinstance.service
    hits_metric = service.metrics.find_by(system_name: 'hits')
    FactoryGirl.create_list(:metric, 2, service: service, parent: hits_metric)
    FactoryGirl.create(:plan_metric, visible: false, metric: service.method_metrics.last!)
    FactoryGirl.create_list(:metric, 2, service: service, parent: nil)
    FactoryGirl.create(:plan_metric, visible: false, metric: service.metrics.top_level.last!)

    get summary_stats_data_applications_path(@cinstance, format: :json)
    json_response = JSON.parse(response.body)
    top_level_metrics_response = (json_response['metrics'] || []).map { |metric| metric.dig('metric', 'id') }
    method_metrics_response = (json_response['methods'] || []).map { |method| method.dig('metric', 'id') }
    assert_same_elements service.metrics.top_level.visible_for_plan(@cinstance).map(&:id), top_level_metrics_response
    assert_same_elements service.method_metrics.visible_for_plan(@cinstance).map(&:id), method_metrics_response
  end
end
