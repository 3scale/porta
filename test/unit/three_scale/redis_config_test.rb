# frozen_string_literal: true

require 'test_helper'

module ThreeScale
  class RedisConfigTest < ActiveSupport::TestCase
    test '#db' do
      assert_equal 4, RedisConfig.new(db: 4).db
      assert_equal 3, RedisConfig.new(url: 'redis://my-redis/3').db
      assert_equal 0, RedisConfig.new(url: 'redis://my-redis').db
    end

    test '#reverse_merge' do
      config_1 = RedisConfig.new(host: 'localhost', db: 1)
      config_2 = RedisConfig.new(db: 2, password: 'passwd')

      assert_equal({ host: 'localhost', db: 1, id: nil, password: 'passwd' }, config_1.reverse_merge(config_2))
      assert_equal({ host: 'localhost', db: 1, id: nil }, config_1.config)
    end

    test '#reverse_merge!' do
      config_1 = RedisConfig.new(host: 'localhost', db: 1)
      config_2 = RedisConfig.new(db: 2, password: 'passwd')

      assert_equal({ host: 'localhost', db: 1, id: nil, password: 'passwd'}, config_1.reverse_merge!(config_2))
      assert_equal({ host: 'localhost', db: 1, id: nil, password: 'passwd' }, config_1.config)
    end

    test 'sentinels' do
      config = RedisConfig.new(url: 'redis://my-redis/1', sentinels: 'redis://:abc@127.0.0.1,localhost,redis://:passwd@external-redis,redis://localhost:1234')
      expected_sentinels = [
        { host: '127.0.0.1', port: 26379, password: 'abc' },
        { host: 'localhost', port: 26379 },
        { host: 'external-redis', port: 26379, password: 'passwd' },
        { host: 'localhost', port: 1234 },
      ]
      assert_equal expected_sentinels, config.sentinels
    end

    test 'sets redis client id to nil when id is not provided' do
      config = RedisConfig.new(url: 'redis://my-redis/1')

      assert_nil config.id
      assert config.key? :id
    end

    # The ID is forced to be nil to disable the default behavior in Sidekiq < 6
    # which invokes CLIENT SETNAME command, which incompatible with some Redis providers
    # see https://issues.redhat.com/browse/THREESCALE-9210
    test 'sets redis client id to nil when id is set explicitly' do
      config = RedisConfig.new(url: 'redis://my-redis/1', id: 'redis-client-name')
      assert_nil config.id
      assert config.key? :id
    end
  end
end
