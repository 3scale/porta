require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Stats::Aggregation::RuleTest < ActiveSupport::TestCase
  def setup
    @storage = Stats::Base.storage
    @storage.flushdb
  end

  test 'sets expiration time for volatile keys' do
    service = Factory :service
    rule = Stats::Aggregation::Rule.new(:service, :granularity => :day, :expires_in => 2.days)
    time = Time.zone.now

    data = {:service    => service.id,
            :cinstance  => 456,
            :usage      => NumericHash.new(789 => 1),
            :created_at => time}

    rule.aggregate(data)
    key = "stats/{service:#{service.backend_id}}/metric:789/day:#{time.beginning_of_cycle(:day).to_s(:compact)}"

    ttl = @storage.ttl(key)

    assert_not_equal -1, ttl
    assert_in_delta 2.days, ttl.seconds, 1.minute
  end
end
