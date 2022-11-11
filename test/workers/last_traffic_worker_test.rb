require 'test_helper'

class LastTrafficWorkerTest < SimpleMiniTest
  def test_perform
    freeze_time do
      last_traffic = LastTraffic.new(provider)
      LastTraffic.stubs(new: last_traffic)
      last_traffic.expects(:sent_traffic_on).with(Time.now).returns(Date.today)
      LastTrafficWorker.new.perform(provider.id)
    end
  end

  def test_perform_no_traffic
    LastTraffic.any_instance.expects(:sent_traffic_on)
    LastTrafficWorker.new.perform(provider.id)
  end

  def test_perform_yesterday
    date = Date.yesterday
    time = date.to_time
    last_traffic = LastTraffic.new(provider)
    LastTraffic.stubs(new: last_traffic)
    last_traffic.expects(:sent_traffic_on).with(time)
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
