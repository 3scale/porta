# frozen_string_literal: true

require 'test_helper'

class RedisConnectionErrorTest < ActiveSupport::TestCase
  test 'Name or service not known' do
    redis_config = ThreeScale::RedisConfig.new(
      url: 'redis://mymaster',
      sentinels: 'invalid_host:26380,other_invalid_host:26381',
      role: :master
    ).config

    redis = Redis.new(redis_config)

    exception = assert_raises(RedisClient::CannotConnectError) { redis._client.send(:connect) }
    assert_equal 'No sentinels available', exception.message
  end
end
