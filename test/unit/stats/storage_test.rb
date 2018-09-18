require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Stats::StorageTest < ActiveSupport::TestCase
  include Stats
  include Stats::KeyHelpers

  test 'Storage#values_in_range' do
    storage = Storage.instance
    storage.flushdb

    service = Factory(:service)
    metric  = Factory(:metric, :service => service)

    # some fake data
    storage.set("stats/{service:#{service.backend_id}}/metric:#{metric.id}/day:20091210", 12)
    storage.set("stats/{service:#{service.backend_id}}/metric:#{metric.id}/day:20091211", 13)
    storage.set("stats/{service:#{service.backend_id}}/metric:#{metric.id}/day:20091218", 14)

    results = storage.values_in_range(Time.zone.local(2009, 12, 1)..Time.zone.local(2009, 12, 31), :day, [:stats, service, metric])


    assert_equal [0] * 9 + [12, 13] + [0] * 6 + [14] + [0] * 13, results
  end

  test 'Storage#ordered_hash' do
    storage = Storage.instance
    storage.flushdb

    service = Factory(:service)
    metric = Factory(:metric)
    cinstance1 = Factory(:cinstance)
    cinstance2 = Factory(:cinstance)

    # fake data
    storage.set("stats/{service:#{service.backend_id}}/cinstance:#{cinstance1.id}/metric:#{metric.id}/day:20091211", 12)
    storage.set("stats/{service:#{service.backend_id}}/cinstance:#{cinstance2.id}/metric:#{metric.id}/day:20091211", 4)

    storage.sadd("stats/{service:#{service.backend_id}}/cinstances", cinstance1.id)
    storage.sadd("stats/{service:#{service.backend_id}}/cinstances", cinstance2.id)

    Time.use_zone 'Pacific Time (US & Canada)' do
      results = storage.ordered_hash(Time.zone.local(2009,12,11),:day,
                                     :from  => [:stats, service, :cinstances],
                                     :by    => [:stats, service, {:cinstance => :*}, metric ],
                                     :order => :desc)

      expected = string_hash(cinstance2.id => 4, cinstance1.id => 12)
      results = string_hash(results)

      assert_equal expected, results
    end
  end

  def string_hash(hash)
    hash.map{|key,val| [key.to_s, val.to_s] }.to_h
  end
end
