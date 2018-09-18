require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class BackendClient::Provider::TransactionsTest < ActiveSupport::TestCase

  include TestHelpers::FakeWeb

  def setup
    set_backend_host 'example.org'

    @provider_account = Factory(:provider_account)
    @provider_key     = @provider_account.api_key

    @connection = BackendClient::Connection.new(:host => backend_host)
    @provider   = @connection.provider(@provider_account)
  end

  # TODO: #latest_transactions with invalid metric_id
  # TODO: #latest_transactions and timezones

  test '#latest_transactions returns empty array if response contains no entries' do
    transactions = ThreeScale::Core::APIClient::Collection.new([])
    ThreeScale::Core::Transaction.expects(:load_all).with(@provider_account.default_service.backend_id).returns(transactions)

    assert_equal [], @provider.latest_transactions
  end

  test '#latest_transactions returns collection of transaction objects' do
    plan          = Factory(:application_plan, :issuer => @provider_account.default_service)

    cinstance_one = Factory(:cinstance, :plan => plan)
    cinstance_two = Factory(:cinstance, :plan => plan)

    metric_one    = Factory(:metric, :service => @provider_account.default_service)
    metric_two    = Factory(:metric, :service => @provider_account.default_service)

    transactions = [
      {:application_id => cinstance_one.application_id, :timestamp => "2010-09-13 14:14:00 UTC",
       :usage => {metric_one.id.to_s => 1, metric_two.id.to_s => 10000} },
      {:application_id => cinstance_two.application_id, :timestamp => "2010-09-13 14:10:00 UTC",
       :usage => {metric_one.id.to_s => 2, metric_two.id.to_s => 7000} }
    ]
    transactions.map! { |attr| ThreeScale::Core::Transaction.new(attr.deep_symbolize_keys) } # usage keys (the metric ids) are actually provided as Symbol by ThreeScale::Core
    transactions = ThreeScale::Core::APIClient::Collection.new(transactions)
    ThreeScale::Core::Transaction.expects(:load_all).with(@provider_account.default_service.backend_id).returns(transactions)

    @provider_account.reload
    @provider_account.default_service.reload
    transactions = @provider.latest_transactions

    assert_equal 2, transactions.size

    assert_equal cinstance_one,                          transactions[0].cinstance
    assert_equal Time.utc(2010, 9, 13, 14, 14),          transactions[0].timestamp
    assert_equal({metric_one => 1, metric_two => 10000}, transactions[0].usage)

    assert_equal cinstance_two,                          transactions[1].cinstance
    assert_equal Time.utc(2010, 9, 13, 14, 10),          transactions[1].timestamp
    assert_equal({metric_one => 2, metric_two => 7000},  transactions[1].usage)
  end

  test '#latest_transactions converts timestamps to the current timezone' do
    plan      = Factory( :application_plan, :issuer => @provider_account.default_service)
    cinstance = Factory(:cinstance, :plan => plan)
    metric    = @provider_account.default_service.metrics.hits

    transactions = [
      {:application_id => cinstance.application_id, :timestamp => "2010-09-23 14:25:00 UTC",
       :usage => {metric.id.to_s => 1} }
    ]
    transactions.map! { |attr| ThreeScale::Core::Transaction.new(attr.deep_symbolize_keys) } # usage keys (the metric ids) are actually provided as Symbol by ThreeScale::Core
    transactions = ThreeScale::Core::APIClient::Collection.new(transactions)
    ThreeScale::Core::Transaction.expects(:load_all).with(@provider_account.default_service.backend_id).returns(transactions)

    Time.use_zone('Alaska') do
      transactions = @provider.latest_transactions
      assert_equal Time.utc(2010, 9, 23, 14, 25).in_time_zone('Alaska'), transactions[0].timestamp
    end
  end

  test '#latest_transactions returns transactions with nil cinstance for invalid application id' do
    metric = @provider_account.default_service.metrics.hits
    transactions = [
      {:application_id => 'invalid', :timestamp => "2010-09-23 14:28:00 UTC",
       :usage => {metric.id.to_s => 1} }
    ]
    transactions.map! { |attr| ThreeScale::Core::Transaction.new(attr.deep_symbolize_keys) } # usage keys (the metric ids) are actually provided as Symbol by ThreeScale::Core
    transactions = ThreeScale::Core::APIClient::Collection.new(transactions)
    ThreeScale::Core::Transaction.expects(:load_all).with(@provider_account.default_service.backend_id).returns(transactions)

    assert_nil @provider.latest_transactions.first.cinstance
  end

  test '#latest_transactions sorts transactions from multiple services by timestamp overall' do
    service_a = @provider_account.default_service
    service_b = Factory(:service, account: @provider_account)

    cinstance_one = Factory(:cinstance, :plan => Factory(:application_plan, :issuer => service_a))
    cinstance_two = Factory(:cinstance, :plan => Factory(:application_plan, :issuer => service_b))

    metric_one = Factory(:metric, :service => service_a)
    metric_two = Factory(:metric, :service => service_a)
    metric_three = Factory(:metric, :service => service_b)

    transactions_a = [
      { application_id: cinstance_one.application_id, timestamp: "2017-09-29 10:43:00 UTC", usage: { metric_one.id.to_s => 10, metric_two.id.to_s => 6 } },
      { application_id: cinstance_one.application_id, timestamp: "2017-09-29 10:45:00 UTC", usage: { metric_one.id.to_s => 8 } },
      { application_id: cinstance_one.application_id, timestamp: "2017-09-29 10:51:00 UTC", usage: { metric_one.id.to_s => 9, metric_two.id.to_s => 3 } }
    ].map { |attr| ThreeScale::Core::Transaction.new(attr.deep_symbolize_keys) } # usage keys (the metric ids) are actually provided as Symbol by ThreeScale::Core

    transactions_b = [
      { application_id: cinstance_two.application_id, timestamp: "2017-09-29 10:40:00 UTC", usage: { metric_three.id.to_s => 12 } },
      { application_id: cinstance_two.application_id, timestamp: "2017-09-29 10:47:00 UTC", usage: { metric_three.id.to_s => 2 } }
    ].map { |attr| ThreeScale::Core::Transaction.new(attr.deep_symbolize_keys) } # usage keys (the metric ids) are actually provided as Symbol by ThreeScale::Core

    ThreeScale::Core::Transaction.expects(:load_all).with(service_a.backend_id).returns(transactions_a)
    ThreeScale::Core::Transaction.expects(:load_all).with(service_b.backend_id).returns(transactions_b)

    @provider_account.reload
    service_a.reload
    service_b.reload

    result = @provider.latest_transactions

    assert_equal 5, result.size

    first_of_latest = result.first
    last_of_latest = result.last

    assert_equal cinstance_one,                        first_of_latest.cinstance
    assert_equal Time.utc(2017, 9, 29, 10, 51),        first_of_latest.timestamp
    assert_equal({ metric_one => 9, metric_two => 3 }, first_of_latest.usage)

    assert_equal cinstance_two,                        last_of_latest.cinstance
    assert_equal Time.utc(2017, 9, 29, 10, 40),        last_of_latest.timestamp
    assert_equal({ metric_three => 12 },               last_of_latest.usage)
  end
end
