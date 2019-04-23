# frozen_string_literal: true

require 'test_helper'

module ThreeScale
  class MessageBusConfigTest < ActiveSupport::TestCase
    setup do
      System::Application.config.stubs(redis: { url: 'redis://my-redis/1' })
    end

    test '#redis_db_in' do
      assert_equal 4, MessageBusConfig.redis_db_in(db: 4)
      assert_equal 3, MessageBusConfig.redis_db_in(url: 'redis://my-redis/3')
      assert_equal 0, MessageBusConfig.redis_db_in(url: 'redis://my-redis')
    end

    test '#next_db' do
      assert_equal 1, MessageBusConfig.next_db(0)
      assert_equal 0, MessageBusConfig.next_db(15)
    end

    test '#key_collision_prone?' do
      different_db_configs = [
        [{ url: 'redis://my-redis/0' }, { url: 'redis://my-redis/1' }],
        [{ url: 'redis://my-redis/0' }, { host: 'my-redis', db: '1' }],
        [{ host: 'my-redis', db: '0' }, { url: 'redis://my-redis/1' }],
        [{ host: 'my-redis', db: '0' }, { host: 'my-redis', db: '1' }]
      ]
      different_db_configs.each { |(config1, config2)| refute MessageBusConfig.key_collision_prone?(config1, config2) }

      same_db_configs = [
        [{ url: 'redis://my-redis/0' }, { url: 'redis://my-redis/0' }],
        [{ url: 'redis://my-redis/0' }, { host: 'my-redis', db: '0' }],
        [{ host: 'my-redis', db: '0' }, { url: 'redis://my-redis/0' }],
        [{ host: 'my-redis', db: '0' }, { host: 'my-redis', db: '0' }]
      ]
      same_db_configs.each do |(config1, config2)|
        assert MessageBusConfig.key_collision_prone?(config1, config2)
        refute MessageBusConfig.key_collision_prone?(config1.merge(namespace: 'ns'), config2)
        refute MessageBusConfig.key_collision_prone?(config1, config2.merge(namespace: 'ns'))
        refute MessageBusConfig.key_collision_prone?(config1.merge(namespace: 'ns'), config2.merge(namespace: 'other-ns'))
        assert MessageBusConfig.key_collision_prone?(config1.merge(namespace: 'ns'), config2.merge(namespace: 'ns'))
      end
    end

    test 'uses own config if url is present' do
      config = MessageBusConfig.new(redis: { 'url' => 'redis://my-redis/5' })
      assert_equal 'redis://my-redis/5', config.redis_config[:url]
    end

    test 'inherits default redis config' do
      config = MessageBusConfig.new
      assert_equal 'redis://my-redis/1', config.redis_config[:url]
    end

    test 'prevents key collision when inheriting default redis config' do
      config = MessageBusConfig.new
      assert_equal 'redis://my-redis/1', config.redis_config[:url]
      assert_equal 2, config.redis_config[:db]

      config = MessageBusConfig.new(redis: { url: nil })
      assert_equal 'redis://my-redis/1', config.redis_config[:url]
      assert_equal 2, config.redis_config[:db]

      config = MessageBusConfig.new(redis: { db: 1 })
      assert_equal 'redis://my-redis/1', config.redis_config[:url]
      assert_equal 2, config.redis_config[:db]

      config = MessageBusConfig.new(redis: { db: 8 })
      assert_equal 'redis://my-redis/1', config.redis_config[:url]
      assert_equal 8, config.redis_config[:db]

      config = MessageBusConfig.new(redis: { namespace: 'ns' })
      assert_equal 'redis://my-redis/1', config.redis_config[:url]
      assert_equal 'ns', config.redis_config[:namespace]
    end

    test '#configure_message_bus!' do
      config = { keepalive_interval: 0, backend: :memory }
      MessageBus.expects(:configure).with(config)
      MessageBusConfig.new(config).configure_message_bus!
    end

    test 'configures redis' do
      redis_config = { 'url' => 'redis://my-redis' }
      config = { enabled: true, backend: :redis, redis: redis_config }
      MessageBus.expects(:redis_config=).with(redis_config.symbolize_keys)
      MessageBusConfig.new(config).configure_message_bus!
    end

    test 'enabled/disabled' do
      MessageBus.expects(:off)
      MessageBusConfig.new(enabled: false).configure_message_bus!

      MessageBus.expects(:off).never
      MessageBusConfig.new(enabled: true).configure_message_bus!
    end
  end
end
