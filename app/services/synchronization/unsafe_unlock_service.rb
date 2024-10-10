# frozen_string_literal: true

require 'three_scale/patterns/service'

class Synchronization::UnsafeUnlockService < ThreeScale::Patterns::Service
  # unconditional lock release, dangerous to create race conditions based on a redlock key
  # should only be used for manual intervention in case of extraordinary circumstances
  def initialize(str_resource)
    self.resource = str_resource
  end

  # @return [Integer] number of records removed, should be 0 or 1
  def call
    System.redis.del("lock:#{resource}")
  end

  private

  attr_accessor :resource
end
