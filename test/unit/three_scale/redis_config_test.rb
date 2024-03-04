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

    %i[ca_file ca_path].each do |param|
      test "it takes given #{param} when provided" do
        value = 'any_value'
        raw_config = { url: 'rediss://my-secure-redis/1', ssl_params: {}}
        raw_config[:ssl_params][param] = value

        result = RedisConfig.new(raw_config)

        assert result.key? :ssl_params
        assert result[:ssl_params].key? param
        assert_equal value, result[:ssl_params][param]
      end
    end

    test 'it trusts on CAs in config/ca_cert.pem if no ca_file or ca_path are provided' do
      FakeFS do
        FakeFS::FileSystem.clone(file_fixture_path)
        FakeFS::FileSystem.clone(Rails.root.join('config'))
        FileUtils.cp file_fixture('ca_cert.pem'), Rails.root.join('config')

        result = RedisConfig.new(url: 'rediss://my-secure-redis/1')

        assert result.key? :ssl_params
        assert result[:ssl_params].key? :ca_file
        assert_equal Rails.root.join('config/ca_cert.pem').to_s, result[:ssl_params][:ca_file]
      end
    end

    test 'it trusts on CAs in config/ca_cert.pem if ca_file or ca_path are provided empty' do
      FakeFS do
        FakeFS::FileSystem.clone(file_fixture_path)
        FakeFS::FileSystem.clone(Rails.root.join('config'))
        FileUtils.cp file_fixture('ca_cert.pem'), Rails.root.join('config')

        result = RedisConfig.new(url: 'rediss://my-secure-redis/1', ssl_params: { ca_file: nil, ca_path: ''})

        assert_equal Rails.root.join('config/ca_cert.pem').to_s, result[:ssl_params][:ca_file]
      end
    end

    test "it doesn't trust any CA if no ca_file or ca_path are provided and config/ca_cert.pem doesn't exist" do
      result = RedisConfig.new(url: 'rediss://my-secure-redis/1')

      assert_not result.key? :ssl_params
    end
  end
end
