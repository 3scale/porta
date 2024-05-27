# frozen_string_literal: true

require 'test_helper'

module ThreeScale
  class RedisConfigTest < ActiveSupport::TestCase
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

    test 'extracts the Redis logical DB from the URL' do
      config = RedisConfig.new(url: 'redis://localhost:6379/6')

      assert config.key? :db
      assert_equal '6', config[:db]
      assert_equal '6', config.db
    end

    test 'extracts the sentinels group name from the URL' do
      config = RedisConfig.new({ url: 'redis://redis-master/6', sentinels: 'redis://localhost,redis://localhost:1234' })

      assert config.key? :name
      assert_equal 'redis-master', config[:name]
      assert_equal 'redis-master', config.name
    end

    test "doesn't extract the name when no sentinels are provided" do
      config = RedisConfig.new(url: 'redis://redis-master/6')

      assert_not config.key? :name
    end

    test "it takes given ca_file when provided" do
      value = 'any_value'
      raw_config = { url: 'rediss://my-secure-redis/1', ssl_params: {}}
      raw_config[:ssl_params][:ca_file] = value

      result = RedisConfig.new(raw_config)

      assert result.key? :ssl_params
      assert result[:ssl_params].key? :ca_file
      assert_equal value, result[:ssl_params][:ca_file]
    end

    test "it doesn't set CA if no ca_file is provided in config" do
      result = RedisConfig.new(url: 'rediss://my-secure-redis/1')

      assert_not result.key? :ssl_params
    end
  end
end
