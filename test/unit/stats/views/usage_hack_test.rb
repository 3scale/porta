require 'test_helper'
class Stats::Views::UsageHackTest < ActiveSupport::TestCase

  def setup
    @storage = Stats::Base.storage
    @storage.flushdb
  end

  def prepare_stats
    @cinstance = Factory(:cinstance)
    @stats = Stats::Client.new(@cinstance)
    @stats.extend(Stats::Views::UsageHack)
  end

  test 'should raise if no storage assigned' do
    prepare_stats
    assert_raise(Stats::Views::UsageHack::NoStorageException) do
      @stats.storage
    end
  end

  test 'fake_to_cache' do
    prepare_stats
    @storage.mset ['a', 2, 'c', 3]
    @stats.send(:fake_to_cache, ['a', 'c'])
    assert_kind_of Stats::Views::UsageHack::StorageCache, @stats.storage
    assert_equal({'a' => 2, 'c' => 3}, @stats.storage.cache)
  end

  test 'map_cache should map keys and value' do
    prepare_stats
    @storage.mset ['a', 2, 'b', 3, 'c', 4]
    key_values = @stats.send(:map_cache, ['b', 'c', 'a'])
    assert_equal({'a' => 2, 'b' => 3, 'c' => 4}, key_values)
  end

  test 'map_cache should not fail with []' do
    prepare_stats
    assert_equal({}, @stats.send(:map_cache, []))
  end

  test 'StorageCache: assign cache' do
    sc = Stats::Views::UsageHack::StorageCache.instance
    cache = {a: 1, b: 2}
    sc.cache = cache
    assert_equal cache, sc.cache
  end

  test 'StorageCache: keys should return cache.keys' do
    sc = Stats::Views::UsageHack::StorageCache.instance
    sc.cache = {a: 1, b: 2}
    assert_equal [:a, :b], sc.keys
  end

  test 'StorageCache: mget should read from @cache and no return nil' do
    sc = Stats::Views::UsageHack::StorageCache.instance
    sc.cache = {a: 1, b: 2, "c" => 3}
    assert_equal [1,2,3], sc.mget(*[:a, :b, 'c'])
    assert_equal [1,2,3], sc.mget(:a, :b, 'c')
    assert_equal [1,2], sc.mget(:a, :b)
    assert_equal [2], sc.mget(:b)
    assert_equal [3], sc.mget('c')
    assert_equal [], sc.mget('foo')
  end

  test 'StorageFake: mget should return Array with the same elements as params with 0' do
    sf = Stats::Views::UsageHack::StorageFake.instance
    assert_equal [0,0,0], sf.mget(:a, :b, :c)
    assert_equal [0,0], sf.mget(:a, :c)
  end

  test 'StorageFake: mget should keep keys on cached_keys' do
    sf = Stats::Views::UsageHack::StorageFake.instance
    sf.mget(:a, :c, :b)
    assert_equal ['a', 'c', 'b'], sf.cached_keys
  end

  test 'StorageFake: mget should not repeat keys on cached_keys' do
    sf = Stats::Views::UsageHack::StorageFake.instance
    sf.mget(:a, :c, :b)
    sf.mget(:c, :d, :b)
    assert_equal ['a', 'c', 'b', 'd'], sf.cached_keys
  end
end
