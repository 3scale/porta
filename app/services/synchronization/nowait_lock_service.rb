# frozen_string_literal: true

class Synchronization::NowaitLockService < Patterns::Service
  class << self
    # workarounds https://github.com/Selleo/pattern/issues/39
    def call(*args, &block)
      args.last[:block] = block if block
      super(*args)
    end
  end

  # @param str_resource [String] a lock key
  # @param timeout [Integer] milliseconds lock timeout
  # @param block if nobody else holds the lock, then release the lock
  def initialize(str_resource, timeout:, block: nil)
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
    # we may cache this as thread/fiber local variable but for now creating a new one is sufficient
    # important is for individual workers to use a different clients, otherwise locks will be confused
    Redlock::Client.new([System.redis], { retry_count: 0, redis_timeout: 1 })
  end
end
