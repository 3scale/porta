# frozen_string_literal: true

require "test_helper"

class Synchronization::NowaitLockServiceTest < ActionDispatch::IntegrationTest
  attr_reader :lock_key

  setup do
    @lock_key = SecureRandom.uuid
  end

  test "locks then cannot lock but can lock after unlock" do
    assert Synchronization::NowaitLockService.call(lock_key, timeout: 10000).result
    assert_not Synchronization::NowaitLockService.call(lock_key, timeout: 10000).result
    assert_equal 1, Synchronization::UnsafeUnlockService.call(lock_key).result
    assert_equal 0, Synchronization::UnsafeUnlockService.call(lock_key).result
    assert Synchronization::NowaitLockService.call(lock_key, timeout: 100).result
  end

  test "locks between threads" do
    Thread.new do
      assert Synchronization::NowaitLockService.call(lock_key, timeout: 10000).result
    end.join
    assert_not Synchronization::NowaitLockService.call(lock_key, timeout: 10000).result
  end

  test "locks with a block" do
    wait = nil
    thread = Thread.new do
      Synchronization::NowaitLockService.call(lock_key, timeout: 10000) do
        wait = true
        sleep 0.001 while wait
      end
    end
    200.times { sleep 0.01 unless wait } # wait up to 2s for thread to acquire lock
    assert_not Synchronization::NowaitLockService.call(lock_key, timeout: 10000).result
    wait = false
    assert thread.join(1)
    assert Synchronization::NowaitLockService.call(lock_key, timeout: 100).result
  ensure
    thread.kill
  end

  test "locks expire" do
    assert Synchronization::NowaitLockService.call(lock_key, timeout: 100).result
    sleep 0.12
    assert Synchronization::NowaitLockService.call(lock_key, timeout: 100).result
  end

  test "lock_key prefixes resource with 'lock:'" do
    service = Synchronization::NowaitLockService.new("billing:123", timeout: 10000)

    assert_equal "lock:billing:123", service.send(:lock_key)
  end

  test "accepts timeout as keyword argument" do
    timeout_ms = 5000
    service = Synchronization::NowaitLockService.new(lock_key, timeout: timeout_ms)

    assert_equal timeout_ms, service.send(:timeout)
  end
end
