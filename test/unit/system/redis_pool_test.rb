# frozen_string_literal: true

require 'test_helper'

class System::RedisPoolTest < ActiveSupport::TestCase
  test 'config' do
    ConnectionPool.expects(:new).with(timeout: 5, size: 5).at_least_once
    pool = System::RedisPool.new
    ConnectionPool.expects(:new).with(size: 3, timeout: 7).at_least_once
    pool = System::RedisPool.new(size: 3, pool_timeout: 7)
  end

  test 'delegation' do
    redis = mock
    redis.expects(:ping).returns('PONG')
    Redis.expects(:new).returns(redis)

    pool = System::RedisPool.new
    pool.ping
  end
end
