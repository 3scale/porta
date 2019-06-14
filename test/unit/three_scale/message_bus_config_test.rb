# frozen_string_literal: true

require 'test_helper'

module ThreeScale
  class MessageBusConfigTest < ActiveSupport::TestCase
    setup do
      System::Application.config.stubs(redis: { url: 'redis://my-redis/1' })
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
