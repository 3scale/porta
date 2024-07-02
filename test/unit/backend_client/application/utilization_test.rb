require 'test_helper'

class BackendClient::Application::UtilizationTest < ActiveSupport::TestCase
  def setup
    provider_account = FactoryBot.create(:provider_account)
    @provider_key    = provider_account.api_key

    @application_plan = FactoryBot.create( :application_plan, :issuer => provider_account.default_service)
    cinstance         = FactoryBot.create(:cinstance, :plan => @application_plan)
    @application_id   = cinstance.application_id
    @service_id       = cinstance.service.backend_id

    connection   = BackendClient::Connection.new(host: 'example.org')
    provider     = connection.provider(provider_account)
    @application = provider.application(cinstance)
  end

  # TODO: more tests - for infinity stuff, ordering and others

  def test_parsing_backend_output
    metric = @application_plan.metrics.first

    utilization_records = ThreeScale::Core::APIClient::Collection.new([
      ThreeScale::Core::Utilization.new({ period: 'day', metric_name: metric.name, max_value: 10000, current_value: 9000 })
    ])
    ThreeScale::Core::Utilization.expects(:load).with(@service_id, @application_id).returns(utilization_records)

    utilization = @application.utilization([metric])

    assert_equal 1, utilization.size
    record = utilization.first

    assert_equal 'day', record.period
    assert_equal 10000, record.max_value
    assert_equal 9000, record.current_value
    assert_equal metric.name, record.system_name
    assert_equal metric.friendly_name, record.friendly_name
  end

  def test_output_order
    metrics = FactoryBot.create_list(:metric, 3, owner: @application_plan.issuer)

    utilization_records = ThreeScale::Core::APIClient::Collection.new([
      { period: 'day', metric_name: metrics.first.name, max_value: 5000, current_value: 2500 },
      { period: 'year', metric_name: metrics.second.name, max_value: 10000, current_value: 9000 },
      { period: 'minute', metric_name: metrics.third.name, max_value: 0, current_value: 3000 }
    ].map { |attr| ThreeScale::Core::Utilization.new(attr) })

    ThreeScale::Core::Utilization.expects(:load).with(@service_id, @application_id).returns(utilization_records)

    utilization = @application.utilization(metrics)

    assert_equal 3, utilization.size

    assert_equal 3000, utilization.first.current_value
    assert_equal 0.0, utilization.first.percentage

    assert_equal 9000, utilization.second.current_value
    assert_equal 90.0, utilization.second.percentage

    assert_equal 2500, utilization.third.current_value
    assert_equal 50.0, utilization.third.percentage
  end

  test 'backend metrics are shown' do
    service = @application_plan.issuer
    backend_api = service.backend_apis.first
    metrics = [service.metrics.hits, backend_api.metrics.hits]

    utilization_records = ThreeScale::Core::APIClient::Collection.new([
      { period: 'minute', metric_name: metrics.first.system_name, max_value: 0, current_value: 3000 },
      { period: 'minute', metric_name: metrics.second.system_name, max_value: 0, current_value: 150 }
    ].map { |attr| ThreeScale::Core::Utilization.new(attr) })

    ThreeScale::Core::Utilization.expects(:load).with(@service_id, @application_id).returns(utilization_records)

    utilization = @application.utilization(metrics)

    assert_equal 2, utilization.size
    assert_same_elements [service, backend_api], utilization.map { |record| record.metric.owner }
  end

  test 'utilization records are immutable' do
    attributes = { period: 'day', metric_name: @application_plan.metrics.first.name, max_value: 5000, current_value: 2500 }
    record = UtilizationRecord.new(attributes)
    assert record.frozen?
  end

  test 'metrics not requested should be ignored' do
    metrics = FactoryBot.create_list(:metric, 3, owner: @application_plan.issuer)

    utilization_records = ThreeScale::Core::APIClient::Collection.new([
      { period: 'day', metric_name: metrics.first.name, max_value: 5000, current_value: 2500 },
      { period: 'day', metric_name: metrics.second.name, max_value: 10000, current_value: 9000 },
      { period: 'minute', metric_name: metrics.third.name, max_value: 0, current_value: 3000 }
    ].map { |attr| ThreeScale::Core::Utilization.new(attr) })

    ThreeScale::Core::Utilization.expects(:load).with(@service_id, @application_id).returns(utilization_records)

    requested_metrics = [metrics.first, metrics.last]

    utilization = @application.utilization(requested_metrics)

    assert_equal 2, utilization.size
    assert_same_elements requested_metrics, utilization.map(&:metric)
  end

  test 'nil result returns empty utilizations' do
    ThreeScale::Core::Utilization.expects(:load).with(@service_id, @application_id).returns(nil)

    assert_equal [], @application.utilization([])
  end
end
