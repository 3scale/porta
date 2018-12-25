require 'test_helper'

class LastTrafficTest < ActiveSupport::TestCase
  include LastTraffic
  delegate :storage, to: Stats::Client

  def test_sent_traffic_on
    provider = FactoryBot.create(:provider_account)

    today = Date.today
    time = today.to_time

    traffic = sequence('traffic')

    TrafficService.any_instance.expects(:per_day)
        .with(since: today, till: today).returns([42]).in_sequence(traffic)
    TrafficService.any_instance.expects(:per_day)
        .with(since: today.beginning_of_month, till: today).returns([42, 42]).in_sequence(traffic)

    ThreeScale::Analytics::UserTracking::Segment
        .expects(:track)
        .with(has_entries(event: 'Daily Traffic', properties: has_entries(date: today, value: 42)))

    ThreeScale::Analytics::UserTracking::Segment
        .expects(:track)
        .with(has_entries(event: 'Month Traffic', properties: has_entries(date: today, value: 42*2)))


    assert_equal 42, sent_traffic_on(provider, time)
  end

  def test_send_traffic_in_day
    now = Time.now
    cinstance = FactoryBot.build_stubbed(:cinstance)
    LastTraffic.send_traffic_in_day(cinstance, now)

    assert_equal 1, LastTrafficWorker.jobs.size
    job, * = LastTrafficWorker.jobs

    assert_equal (now + 1.day).to_f, job.fetch('at')
    assert_equal [cinstance.user_account.id, now.to_i], job.fetch('args')
  end
end
