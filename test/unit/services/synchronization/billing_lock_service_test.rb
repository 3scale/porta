# frozen_string_literal: true

require "test_helper"

class Synchronization::BillingLockServiceTest < ActionDispatch::IntegrationTest
  include BillingResultsTestHelpers

  setup do
    @account_id = SecureRandom.random_number(100000).to_s
  end

  teardown do
    clear_billing_locks
  end

  test "initializes with account_id and creates billing resource key" do
    service = Synchronization::BillingLockService.new(@account_id)

    assert_equal @account_id, service.account_id
    assert_equal "lock:billing:#{@account_id}", service.send(:lock_key)
  end

  test "uses default timeout of 1 hour" do
    service = Synchronization::BillingLockService.new(@account_id)

    assert_equal 1.hour.in_milliseconds, service.send(:timeout)
  end

  test "allows custom timeout" do
    custom_timeout = 30.minutes.in_milliseconds
    service = Synchronization::BillingLockService.new(@account_id, timeout: custom_timeout)

    assert_equal custom_timeout, service.send(:timeout)
  end

  test "lock acquires lock and stores lock info" do
    service = Synchronization::BillingLockService.new(@account_id)

    service.lock

    assert_not_nil service.lock_info
    assert_instance_of Hash, service.lock_info
    assert service.lock_info.key?(:validity)
    assert service.lock_info.key?(:resource)
  end

  test "lock raises LockBillingError when lock is already held" do
    service1 = Synchronization::BillingLockService.new(@account_id)
    service2 = Synchronization::BillingLockService.new(@account_id)

    service1.lock

    error = assert_raises(Finance::LockBillingError) do
      service2.lock
    end

    assert_match(/Concurrent billing job already running for account #{@account_id}/, error.message)
  end

  test "unlock releases the lock" do
    service1 = Synchronization::BillingLockService.new(@account_id)
    service2 = Synchronization::BillingLockService.new(@account_id)

    # First service acquires lock
    service1.lock

    # Second service cannot acquire lock
    assert_raises(Finance::LockBillingError) { service2.lock }

    # First service releases lock
    service1.unlock

    # Now second service can acquire lock
    assert_nothing_raised { service2.lock }

    service2.unlock
  end

  test "unlock is idempotent and does not raise if lock is not held" do
    service = Synchronization::BillingLockService.new(@account_id)

    # Unlock without locking should not raise
    assert_nothing_raised { service.unlock }

    # Lock and unlock
    service.lock
    service.unlock

    # Unlock again should not raise
    assert_nothing_raised { service.unlock }
  end

  test "unlock sets lock_info to nil" do
    service = Synchronization::BillingLockService.new(@account_id)

    service.lock
    assert_not_nil service.lock_info

    service.unlock
    assert_nil service.lock_info
  end

  test "unlock logs warning if unlock fails" do
    service = Synchronization::BillingLockService.new(@account_id)
    service.lock

    # Simulate unlock failure
    service.send(:manager).expects(:unlock).raises(StandardError.new("Redis error"))

    Rails.logger.expects(:warn).with(
      "Failed to release billing lock for account #{@account_id}: Redis error"
    )

    service.unlock
  end

  test "works with block when called" do
    executed = false

    result = Synchronization::BillingLockService.new(@account_id, timeout: 10000) do
      executed = true
    end.call

    assert executed, "Block should have been executed"
    assert result, "Should return truthy value when block executes successfully"
  end

  test "different account IDs have separate locks" do
    account_id_1 = "123"
    account_id_2 = "456"

    service1 = Synchronization::BillingLockService.new(account_id_1)
    service2 = Synchronization::BillingLockService.new(account_id_2)

    # Both should be able to acquire locks simultaneously
    assert_nothing_raised { service1.lock }
    assert_nothing_raised { service2.lock }

    service1.unlock
    service2.unlock
  end

  test "lock expires after timeout" do
    service1 = Synchronization::BillingLockService.new(@account_id, timeout: 100)
    service2 = Synchronization::BillingLockService.new(@account_id, timeout: 100)

    service1.lock

    # Wait for lock to expire
    sleep 0.12

    # Should be able to acquire lock again
    assert_nothing_raised { service2.lock }

    service2.unlock
  end

  test "inherits from NowaitLockService" do
    assert Synchronization::BillingLockService < Synchronization::NowaitLockService
  end

  test "call method works via parent class" do
    # The parent NowaitLockService has a call method that should work
    result = Synchronization::BillingLockService.new(@account_id, timeout: 10000).call

    assert result, "Should successfully acquire lock via call method"
  end
end
