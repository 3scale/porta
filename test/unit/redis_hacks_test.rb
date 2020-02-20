# frozen_string_literal: true

require 'test_helper'

class RedisHacksTest < ActiveSupport::TestCase
  test 'Name or service not known' do
    redis_config = ThreeScale::RedisConfig.new(
      url: 'redis://mymaster',
      pool_size: 5,
      pool_timeout: 5,
      sentinels: '127.0.0.1:26380,localhost:26381',
      role: :master
    ).config

    redis = Redis.new(redis_config)
    redis_client = redis.client

    sentinel_1_options = build_sentinel_options(redis_client, redis_config[:sentinels].first)
    sentinel_2_options = build_sentinel_options(redis_client, redis_config[:sentinels].second)

    Redis::Client.expects(:new).with(sentinel_1_options).returns(sentinel_1 = mock)
    Redis::Client.expects(:new).with(sentinel_2_options).returns(sentinel_2 = mock)

    sentinel_1.expects(:call).raises(RuntimeError.new('Name or service not known'))
    sentinel_1.expects(:disconnect)
    sentinel_2.expects(:call).returns(sentinel_2_options.values_at(:host, :port))
    sentinel_2.expects(:disconnect)

    exception = assert_raises(Redis::CannotConnectError) { redis_client.send(:establish_connection) }
    assert_equal 'Error connecting to Redis on localhost:26381 (Errno::ECONNREFUSED)', exception.message
  end

  protected

  def build_sentinel_options(redis_client, sentinel)
    options = redis_client.instance_variable_get(:@options).dup
    options.delete(:sentinels)
    options.merge!(
      db: 0,
      host: sentinel[:host],
      port: sentinel[:port],
      password: sentinel[:password],
      reconnect_attempts: 0
    )
  end
end
