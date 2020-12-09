# frozen_string_literal: true

class DeletionLock < ApplicationRecord
  class LockDeletionError < StandardError; end

  def self.call_with_lock(lock_key:, debug_info: nil, &block)
    lock(lock_key: lock_key, debug_info: debug_info)
    yield
  ensure
    unlock(lock_key: lock_key, debug_info: debug_info)
  end

  def self.lock(lock_key:, debug_info: nil)
    lock = new(lock_key: lock_key)

    raise LockDeletionError, "Could not lock #{lock_key}.  #{debug_info}" unless lock.save

    Rails.logger.info "DeletionLock created for #{lock_key}.  #{debug_info}"
  end

  def self.unlock(lock_key:, debug_info: nil)
    DeletionLock.where(lock_key: lock_key).delete_all
    Rails.logger.info "DeletionLock deleted for #{lock_key}. #{debug_info}"
  end
end
