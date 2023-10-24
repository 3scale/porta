require 'test_helper'

class Backend::StorageTest < ActiveSupport::TestCase

  def given_redis_config(yaml)
    FakeFS do
      config = Rails.root.join('config', 'backend_redis.yml')
      FakeFS::FileSystem.clone(config.dirname, '/tmp/config')
      config.open('w') { |f| f.puts(yaml) }
      yield
    end
  end

  test 'loads config options from config file' do
    yaml = %{
production:
  db: 0
development:
  db: 1
test:
  host: example.com
  port: 1337
  db: 2
}
    given_redis_config(yaml) do
      mock = mock(id: 'redis://localhost:6389/1')
      Redis.expects(:new).with(host: 'example.com', port: 1337, db: 2).returns(mock)

      storage = Backend::Storage.clone.instance
      assert_equal 'redis://localhost:6389/1', storage.id
    end
  end

  test 'parse config' do
    yaml = %{
test:
  host: example.com
  port: 1337
  db: 2
}
    given_redis_config(yaml) do
      assert_equal({ :host => 'example.com', :port => 1337, :db => 2 }, Backend::Storage.parse_config )
    end
  end

  test 'basic operations work' do
    storage = Backend::Storage.instance
    storage.set('foo', 'stuff')

    value = storage.get('foo')
    assert_equal 'stuff', value
  end

  test 'set_object serializes and get_object deserializes the object' do
    storage = Backend::Storage.instance

    object_before_store = {:name => 'Eric Cartman', :age => 9}
    storage.set_object('foo', object_before_store)

    object_after_store = storage.get_object('foo')
    assert_equal object_before_store, object_after_store
  end

  test 'get_object return nil if value does not exist' do
    storage = Backend::Storage.instance
    storage.del('foo')

    assert_nil storage.get_object('foo')
  end

  test 'incrby_and_expire increments' do
    storage = Backend::Storage.instance

    storage.set('foo', 42)
    storage.incrby_and_expire('foo', 22, 1.hour)

    assert_equal '64', storage.get('foo')
  end

  test 'incrby_and_expire sets expiration' do
    storage = Backend::Storage.instance

    storage.set('foo', 42)
    storage.incrby_and_expire('foo', 22, 1.hour)

    ttl = storage.ttl('foo')
    assert ttl > 0
    assert ttl <= 1.hour
  end

  test 'thread safety of Backend::Storage.instance' do
    # skip 'Backend::Storage.instance is not thread safe'

    # Well I am testing ruby Singleton implementaton here
    # Before switching to the Singleton pattern we used non-threadsafe class variable:
    # Backend::Storage.class_variable_set :@@instance, nil
    Backend::Storage.instance_eval { @singleton__instance__ = nil}

    threads = Array.new(5) do
      Thread.new do
        Thread.current[:value] = Backend::Storage.instance.object_id
      end
    end
    threads.map(&:join)
    object_ids = threads.map{|t| t[:value]}.uniq

    assert_equal 1, object_ids.size
  end
end
