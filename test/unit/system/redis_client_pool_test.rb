# frozen_string_literal: true

require 'test_helper'

class System::RedisClientPoolTest < ActiveSupport::TestCase
  test 'new pool' do
    config = { url: 'redis://redis-host:6379', username: 'user', password: 'passwd', pool_size: 2, pool_timeout: 10 }
    pool = System::RedisClientPool.new_pool(config)

    assert_instance_of RedisClient::Pooled, pool
    pool_kwargs = pool.instance_variable_get(:@pool_kwargs)
    assert_equal 2, pool_kwargs[:size]
    assert_equal 10, pool_kwargs[:timeout]

    pool.with do |client|
      assert_instance_of RedisClient, client
      conf = client.config
      assert_instance_of RedisClient::Config, conf
      assert_equal 'redis-host', conf.host
      assert_equal 6379, conf.port
      assert_equal 'user', conf.username
      assert_equal 'passwd', conf.password
    end
  end

  test 'uses system redis config by default' do
    System::Application.config.stubs(redis: { url: 'redis://system-redis:6379', pool_size: 1, pool_timeout: 1 })

    pool = System::RedisClientPool.new_pool

    assert_instance_of RedisClient::Pooled, pool
    pool_kwargs = pool.instance_variable_get(:@pool_kwargs)
    assert_equal 1, pool_kwargs[:size]
    assert_equal 1, pool_kwargs[:timeout]

    pool.with do |client|
      conf = client.config
      assert_equal 'system-redis', conf.host
      assert_equal 6379, conf.port
    end
  end

  test 'pool size and timeout default to 5 if not provided' do
    config = { url: 'redis://localhost:6379', username: 'user', password: 'passwd' }

    pool = System::RedisClientPool.new_pool(config)

    assert_instance_of RedisClient::Pooled, pool
    pool_kwargs = pool.instance_variable_get(:@pool_kwargs)
    assert_equal 5, pool_kwargs[:size]
    assert_equal 5, pool_kwargs[:timeout]
  end

  test 'default pool is available for reuse' do
    pool1 = System::RedisClientPool.default
    pool2 = System::RedisClientPool.default

    assert_same pool1, pool2
  end

  test 'new pool with sentinel configs' do
    config = { url: 'redis://redis-master',
               sentinels: 'localhost:56380,localhost:56381,localhost:56382',
               sentinel_username: 'sentinel_user',
               sentinel_password: 'sentinel_passwd',
               role: 'master',
               pool_size: 2, pool_timeout: 10 }
    
    pool = System::RedisClientPool.new_pool(config)

    assert_instance_of RedisClient::Pooled, pool
    pool_kwargs = pool.instance_variable_get(:@pool_kwargs)
    assert_equal 2, pool_kwargs[:size]
    assert_equal 10, pool_kwargs[:timeout]

    pool.with do |client|
      assert_instance_of RedisClient, client
      conf = client.config
      assert_instance_of RedisClient::SentinelConfig, conf
      assert_equal 3, conf.sentinels.size
      assert_equal ['sentinel_user'], conf.sentinels.map(&:username).uniq
      assert_equal ['sentinel_passwd'], conf.sentinels.map(&:password).uniq
      assert_equal ['sentinel_passwd'], conf.sentinels.map(&:password).uniq
      assert_equal 'redis-master', conf.name
    end
  end
end
