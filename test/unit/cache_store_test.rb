require 'test_helper'

class CacheStoreTest < ActionView::TestCase

  test ':null_store can be set as cache store' do
    # cache_store.yml
    # ---
    # test:
    #   - :null_store
    System::Application.any_instance.expects(:config_for).with(:cache_store).returns([:null_store])

    cache = ActiveSupport::Cache.lookup_store(*System::Application.cache_store_config)

    assert_equal ActiveSupport::Cache::NullStore, cache.class
  end

  test ':memory_store can be set as cache store' do
    # cache_store.yml:
    # ---
    # test:
    #   - :memory_store
    #   - :size: 5000
    options = { size: 5000 }
    System::Application.any_instance.expects(:config_for).with(:cache_store).returns([:memory_store, options])

    cache = ActiveSupport::Cache.lookup_store(*System::Application.cache_store_config)

    assert_equal ActiveSupport::Cache::MemoryStore, cache.class
    assert_equal options, cache.options
  end

  test ':file_store can be set as cache store' do
    # cache_store.yml
    # ---
    # test:
    #   - :file_store
    #   - /tmp/test-file-store
    path = '/tmp/test-file-store'
    System::Application.any_instance.expects(:config_for).with(:cache_store).returns([:file_store, path])

    cache = ActiveSupport::Cache.lookup_store(*System::Application.cache_store_config)

    assert_equal ActiveSupport::Cache::FileStore, cache.class
    assert_equal path, cache.cache_path
  end

  test ':mem_cache_store can be set as cache store' do
    # cache_store.yml
    # ---
    # test:
    #   - :mem_cache_store
    #   - localhost:11211
    server = 'localhost:11211'
    System::Application.any_instance.expects(:config_for).with(:cache_store).returns([:mem_cache_store, server])

    cache = ActiveSupport::Cache.lookup_store(*System::Application.cache_store_config)

    assert_equal ActiveSupport::Cache::MemCacheStore, cache.class
    assert_equal server, cache.stats.keys.first
  end

  test ':mem_cache_store accepts multiple servers in a string' do
    # cache_store.yml
    # ---
    # test:
    #   - :mem_cache_store
    #   - localhost:11211,127.0.0.1:11211,3scale.localhost:11211
    servers = 'localhost:11211,127.0.0.1:11211,3scale.localhost:11211'
    System::Application.any_instance.expects(:config_for).with(:cache_store).returns([:mem_cache_store, servers])

    cache = ActiveSupport::Cache.lookup_store(*System::Application.cache_store_config)

    assert_equal ActiveSupport::Cache::MemCacheStore, cache.class
    assert_same_elements servers.split(','), cache.stats.keys
  end

  test ':mem_cache_store accepts multiple servers in a list' do
    # cache_store.yml
    # ---
    # test:
    #   - :mem_cache_store
    #   - localhost:11211
    #   - 127.0.0.1:11211
    #   - 3scale.localhost:11211
    servers = %w[localhost:11211 127.0.0.1:11211 3scale.localhost:11211]
    System::Application.any_instance.expects(:config_for).with(:cache_store).returns([:mem_cache_store, servers])

    cache = ActiveSupport::Cache.lookup_store(*System::Application.cache_store_config)

    assert_equal ActiveSupport::Cache::MemCacheStore, cache.class
    assert_same_elements servers, cache.stats.keys
  end

  test ':mem_cache_store sets SHA256 as default digest algorithm' do
    # cache_store.yml
    # ---
    # test:
    #   - :mem_cache_store
    System::Application.any_instance.expects(:config_for).with(:cache_store).returns([:mem_cache_store])

    cache = ActiveSupport::Cache.lookup_store(*System::Application.cache_store_config)

    assert_equal ActiveSupport::Cache::MemCacheStore, cache.class
    assert_equal({ digest_class: Digest::SHA256 }, cache.options)
  end

  test ':mem_cache_store allows overwriting the default digest algorithm' do
    # cache_store.yml
    # ---
    # test:
    #   - :mem_cache_store
    #   - :digest_class: !ruby/class Digest::SHA1
    options = { digest_class: Digest::SHA1 }
    System::Application.any_instance.expects(:config_for).with(:cache_store).returns([:mem_cache_store, options])

    cache = ActiveSupport::Cache.lookup_store(*System::Application.cache_store_config)

    assert_equal ActiveSupport::Cache::MemCacheStore, cache.class
    assert_equal options, cache.options
  end

  test ':redis_cache_store can be set as cache store' do
    # cache_store.yml
    # ---
    # test:
    #   - :redis_cache_store
    #   - :url: redis://localhost:6379
    options = { url: 'redis://localhost:6379' }
    System::Application.any_instance.expects(:config_for).with(:cache_store).returns([:redis_cache_store, options])

    cache = ActiveSupport::Cache.lookup_store(*System::Application.cache_store_config)

    assert_equal ActiveSupport::Cache::RedisCacheStore, cache.class
    assert_equal options, cache.redis_options
  end
end
