require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Stats::AggregationTest < ActiveSupport::TestCase
  include Stats

  def setup
    @provider_account = FactoryBot.create(:provider_account)
    @service = @provider_account.first_service!
    @metric = @service.metrics.hits!

    @plan = FactoryBot.create( :application_plan, :issuer => @service)
    @cinstance = FactoryBot.create(:cinstance, :plan => @plan)

    @storage = Stats::Base.storage
    @storage.flushdb
  end

  test 'Aggregation.aggregate increments the corresponding day value for the service' do
    transaction = build_transaction_at(Time.utc(2009, 11, 22, 18, 45))

    key = "stats/{service:#{@service.backend_id}}/metric:#{@metric.id}/day:20091122"
    @storage.set(key, 1024)

    assert_change :of => lambda { @storage.get(key) }, :from => '1024', :to => '1025' do
      Aggregation.aggregate(transaction)
    end
  end

  test 'Aggregation.aggregate increments the corresponding hour value for the service' do
    transaction = build_transaction_at(Time.utc(2009, 11, 22, 18, 45))

    key = "stats/{service:#{@service.backend_id}}/metric:#{@metric.id}/hour:2009112218"
    @storage.set(key, 7)

    assert_change :of => lambda { @storage.get(key) }, :from => '7', :to => '8' do
      Aggregation.aggregate(transaction)
    end
  end

  test 'Aggregation.aggregate does not update set of services' do
    transaction = build_transaction_at(Time.zone.now)

    assert_no_change :of => lambda { @storage.smembers('stats/services') } do
      Aggregation.aggregate(transaction)
    end
  end

  test 'Aggregation.aggregate increments the corresponding day value for the cinstance' do
    transaction = build_transaction_at(Time.utc(2009, 11, 22, 16, 45))

    key = "stats/{service:#{@service.backend_id}}/cinstance:#{@cinstance.id}/metric:#{@metric.id}/day:20091122"
    @storage.set(key, 19)

    assert_change :of => lambda { @storage.get(key) }, :from => '19', :to => '20' do
      Aggregation.aggregate(transaction)
    end
  end

  test 'Aggregation.aggregate increments the corresponding month value for the cinstance' do
    transaction = build_transaction_at(Time.utc(2009, 11, 22, 16, 45))

    key = "stats/{service:#{@service.backend_id}}/cinstance:#{@cinstance.id}/metric:#{@metric.id}/month:20091101"
    @storage.set(key, 243)

    assert_change :of => lambda { @storage.get(key) }, :from => '243', :to => '244' do
      Aggregation.aggregate(transaction)
    end
  end

  test 'Aggregation.aggregate increments the corresponding year value for the cinstance' do
    transaction = build_transaction_at(Time.utc(2009, 11, 22, 16, 45))

    key = "stats/{service:#{@service.backend_id}}/cinstance:#{@cinstance.id}/metric:#{@metric.id}/year:20090101"
    @storage.set(key, 4981)

    assert_change :of => lambda { @storage.get(key) }, :from => '4981', :to => '4982' do
      Aggregation.aggregate(transaction)
    end
  end

  test 'Aggregation.aggregate increments the eternal value for the cinstance' do
    transaction = build_transaction_at(Time.utc(2009, 11, 22, 16, 45))

    key = "stats/{service:#{@service.backend_id}}/cinstance:#{@cinstance.id}/metric:#{@metric.id}/eternity"
    @storage.set(key, 7008)

    assert_change :of => lambda { @storage.get(key) }, :from => '7008', :to => '7009' do
      Aggregation.aggregate(transaction)
    end
  end


  test 'Aggregation.aggregate adds the cinstance id to the set of cinstances of the service' do
    transaction = build_transaction_at(Time.zone.now)

    key = "stats/{service:#{@service.backend_id}}/cinstances"

    assert_change :of => lambda { @storage.smembers(key) },
                  :from => [], :to => [@cinstance.id.to_s] do
      Aggregation.aggregate(transaction)
    end
  end

  private

  def build_transaction_at(time)
    {:service    => @service.id,
     :cinstance  => @cinstance.id,
     :usage      => NumericHash.new(@metric.id => 1),
     :created_at => time}
  end
end
