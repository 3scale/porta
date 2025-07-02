# frozen_string_literal: true

class Synchronization::NowaitLockService < ThreeScale::Patterns::Service
  # @param str_resource [String] a lock key
  # @param timeout [Integer] milliseconds lock timeout
  # @yield [] if lock is acquired, then execute block without parameters and ensure lock is released afterwards
  def initialize(str_resource, timeout:, &block)
    self.resource = str_resource
    self.timeout = timeout
    self.block = block
  end

  # @return [Hash, NilClass, TrueClass, FalseClass] without block returns lock_info or nil, otherwise a boolean signifying whether it ran
  def call
    manager.lock("lock:#{resource}", timeout, &block)
  end

  private

  attr_accessor :resource, :block, :timeout

  def manager
    # we may cache this as thread/fiber local variable but for now creating a new one seems good enough
    Redlock::Client.new([System::RedisClientPool.default], { retry_count: 0, redis_timeout: 1 })
  end
end
