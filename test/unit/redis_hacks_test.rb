# frozen_string_literal: true

require 'test_helper'

class RedisHacksTest < ActiveSupport::TestCase
  test 'Name or service not known' do
    redis_config = ThreeScale::RedisConfig.new(
      url: 'redis://mymaster',
      pool_size: 5,
      pool_timeout: 5,
      sentinels: 'invalid_host:26380,other_invalid_host:26381',
      role: :master
    ).config

    redis = Redis.new(redis_config)

    exception = assert_raises(Redis::CannotConnectError) { redis._client.send(:establish_connection) }
    assert_equal 'No sentinels available.', exception.message
  end

  protected

  def build_sentinel_options(redis_client, sentinel)
    options = redis_client.instance_variable_get(:@options).dup
    options.delete(:sentinels)
    options.merge!(
      host: sentinel[:host],
      port: sentinel[:port],
      password: sentinel[:password],
      reconnect_attempts: 0
    )
  end
end
