require 'test_helper'

class LastTrafficWorkerTest < MiniTest::Unit::TestCase

  def setup
  end

  def test_perform
    Timecop.freeze do
      LastTraffic.expects(:sent_traffic_on).with(provider, Time.now).returns(Date.today)
      LastTrafficWorker.new.perform(provider.id)
    end
  end

  def test_perform_no_traffic
    LastTraffic.expects(:sent_traffic_on)
    LastTrafficWorker.new.perform(provider.id)
  end

  def test_perform_yesterday
    date = Date.yesterday
    time = date.to_time
    LastTraffic.expects(:sent_traffic_on).with(provider, time)
    LastTrafficWorker.new.perform(provider.id, time.to_i)
  end

  def test_perform_exception
    refute LastTrafficWorker.new.perform(42)
  end

  def provider
    @provider ||= begin
        provider = stub('provider', id: 42)
        Provider.expects(:find).with(provider.id).returns(provider)
        provider
    end
  end
end
