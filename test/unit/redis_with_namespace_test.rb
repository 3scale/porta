# frozen_string_literal: true
require 'test_helper'

class RedisWithNamespaceTest < ActiveSupport::TestCase
  def test_new_with_namespace
    config = {namespace: 'custom-namespace'}
    redis = Redis.new_with_namespace(config)
    assert_instance_of Redis::Namespace, redis
    assert_equal 'custom-namespace', redis.namespace

    config = {namespace: ''}
    redis = Redis.new_with_namespace(config)
    assert_instance_of Redis, redis

    config = {namespace: nil}
    redis = Redis.new_with_namespace(config)
    assert_instance_of Redis, redis

    redis = Redis.new_with_namespace
    assert_instance_of Redis, redis
  end
end
