# frozen_string_literal: true

class Synchronization::BillingLockService < Synchronization::NowaitLockService

  # Default timeout for billing
  DEFAULT_TIMEOUT = 1.hour.in_milliseconds

  # @param account_id [String] provider account ID for locking
  # @param timeout [Integer] milliseconds lock timeout
  # @yield [] if lock is acquired, then execute block without parameters and ensure lock is released afterwards
  def initialize(account_id, timeout: DEFAULT_TIMEOUT, &block)
    self.account_id = account_id

    resource = "billing:#{account_id}"
    super(resource, timeout: timeout, &block)
  end

  def lock
    @lock_info = manager.lock(lock_key, timeout)
    raise Finance::LockBillingError, "Concurrent billing job already running for account #{account_id}" unless @lock_info

    @lock_info
  end

  def unlock
    manager.unlock(@lock_info) if @lock_info
    @lock_info = nil
  rescue StandardError => exception
    Rails.logger.warn("Failed to release billing lock for account #{account_id}: #{exception.message}")
  end

  private

  attr_accessor :lock_info, :account_id
end
