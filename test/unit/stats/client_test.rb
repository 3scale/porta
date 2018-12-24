require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Stats::ClientTest < ActiveSupport::TestCase
  def setup
    provider_account = FactoryBot.create(:provider_account)
    @service = provider_account.first_service!
    plan = FactoryBot.create(:application_plan, :issuer => @service)
    @metric = @service.metrics.hits!
    @cinstance = FactoryBot.create(:cinstance, :plan => plan)

    @storage = Stats::Base.storage
    @storage.flushdb

    @stats = Stats::Client.new(@cinstance)
  end

  # Regression test for https://www.pivotaltracker.com/story/show/13710485
  #
  test 'Client#usage with period as symbol and start time' do
    @storage.set(stats_key(@metric, 'month:20091201'), 1024)

    assert_raises(Stats::InvalidParameterError) do
      @stats.usage(:metric => @metric,
                   :period => 'DANGEROUS_CODE',
                   :since  => Time.utc(2009, 12, 1))
    end
  end

  test 'Client#total with period as symbol and start time' do
    @storage.set(stats_key(@metric, 'month:20091201'), 1024)

    assert_equal 1024, @stats.total(:metric => @metric,
                                    :period => :month,
                                    :since  => Time.utc(2009, 12, 1))
  end


  test 'Client#total with period as month range' do
    @storage.set(stats_key(@metric, 'month:20101101'), 123)
    range = Month.new(2010, 11)

    assert_equal 123, @stats.total(:metric => @metric, :period => range)
  end

  test 'Client#total with period as day range' do
    @storage.set(stats_key(@metric, 'day:20101115'), 123)
    range = (Time.utc(2010, 11, 15).beginning_of_day .. Time.utc(2010, 11, 15).end_of_day)

    assert_equal 123, @stats.total(:metric => @metric, :period => range)
  end

  test 'Client#total with period as range spanning several days' do
    @storage.set(stats_key(@metric, 'day:20101115'),  10203)
    @storage.set(stats_key(@metric, 'day:20101116'),  40506)
    @storage.set(stats_key(@metric, 'day:20101117'),  70809)
    @storage.set(stats_key(@metric, 'day:20101118'), 101112)

    range = (Time.utc(2010, 11, 15).beginning_of_day .. Time.utc(2010, 11, 17).end_of_day)

    assert_equal 10203 + 40506 + 70809, @stats.total(:metric => @metric, :period => range)
  end

  test 'Client#total with eternity' do
    @storage.set(stats_key(@metric, 'eternity'), 12345)
    assert_equal 12345, @stats.total(:metric => @metric, :period => :eternity)
  end

  private

  def stats_key(metric, time)
    "stats/{service:#{@service.backend_id}}/cinstance:#{@cinstance.application_id}/metric:#{metric.id}/#{time}"
  end
end
