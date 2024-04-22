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

      assert_equal({ host: 'localhost', db: 1, password: 'passwd' }, config_1.reverse_merge(config_2))
      assert_equal({ host: 'localhost', db: 1 }, config_1.config)
    end

    test '#reverse_merge!' do
      config_1 = RedisConfig.new(host: 'localhost', db: 1)
      config_2 = RedisConfig.new(db: 2, password: 'passwd')

      assert_equal({ host: 'localhost', db: 1, password: 'passwd'}, config_1.reverse_merge!(config_2))
      assert_equal({ host: 'localhost', db: 1, password: 'passwd' }, config_1.config)
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

    test ':pool_size is renamed to :size' do
      config = RedisConfig.new(pool_size: 5)

      assert config.key? :size
      assert_equal 5, config[:size]
    end
  end
end
