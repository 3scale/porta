# frozen_string_literal: true

require 'test_helper'

module ThreeScale
  class RedisConfigTest < ActiveSupport::TestCase
    test '#db' do
      assert_equal 4, RedisConfig.new(db: 4).db
      assert_equal 3, RedisConfig.new(url: 'redis://my-redis/3').db
      assert_equal 0, RedisConfig.new(url: 'redis://my-redis').db
    end

    test '#next_db' do
      assert_equal 1, RedisConfig.new(db: 0).send(:next_db)
      assert_equal 0, RedisConfig.new(db: 15).send(:next_db)
    end

    test '#key_collision_prone?' do
      different_db_configs = [
        [{ url: 'redis://my-redis/0' }, { url: 'redis://my-redis/1' }],
        [{ url: 'redis://my-redis/0' }, { host: 'my-redis', db: '1' }],
        [{ host: 'my-redis', db: '0' }, { url: 'redis://my-redis/1' }],
        [{ host: 'my-redis', db: '0' }, { host: 'my-redis', db: '1' }]
      ]
      different_db_configs.each { |(config1, config2)| refute RedisConfig.new(config1).prone_to_key_collision_with?(RedisConfig.new(config2)) }

      same_db_configs = [
        [{ url: 'redis://my-redis/0' }, { url: 'redis://my-redis/0' }],
        [{ url: 'redis://my-redis/0' }, { host: 'my-redis', db: '0' }],
        [{ host: 'my-redis', db: '0' }, { url: 'redis://my-redis/0' }],
        [{ host: 'my-redis', db: '0' }, { host: 'my-redis', db: '0' }]
      ]
      same_db_configs.each do |(config1, config2)|
        assert RedisConfig.new(config1).prone_to_key_collision_with?(RedisConfig.new(config2))
        refute RedisConfig.new(config1.merge(namespace: 'ns')).prone_to_key_collision_with?(RedisConfig.new(config2))
        refute RedisConfig.new(config1).prone_to_key_collision_with?(RedisConfig.new(config2.merge(namespace: 'ns')))
        refute RedisConfig.new(config1.merge(namespace: 'ns')).prone_to_key_collision_with?(RedisConfig.new(config2.merge(namespace: 'other-ns')))
        assert RedisConfig.new(config1.merge(namespace: 'ns')).prone_to_key_collision_with?(RedisConfig.new(config2.merge(namespace: 'ns')))
      end
    end

    test 'rotate db' do
      config = RedisConfig.new(db: 14)
      assert_equal 14, config.db
      config.rotate_db
      assert_equal 15, config.db
      config.rotate_db
      assert_equal 0, config.db
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

    test 'sets redis client id to nil when id not provided' do
      config = RedisConfig.new(url: 'redis://my-redis/1')

      assert_nil config.id
      assert config.key? :id
    end

    test 'sets redis client id to nil when id is set explicitly' do
      config = RedisConfig.new(url: 'redis://my-redis/1', id: 'redis-client-name')
      assert_nil config.id
      assert config.key? :id
    end
  end
end
