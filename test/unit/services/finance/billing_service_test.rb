# frozen_string_literal: true

require 'test_helper'
require 'sidekiq/testing'

class Finance::BillingServiceTest < ActionDispatch::IntegrationTest
  include BillingResultsTestHelpers

  setup do
    @provider = FactoryBot.create(:provider_with_billing)
  end

  teardown do
    clear_locks
  end

  test 'enqueues a sidekiq worker' do
    now = Time.utc(2018, 1, 16)
    BillingWorker.expects(:enqueue).with(@provider, now, nil).returns(true)
    assert Finance::BillingService.async_call(@provider, now)
  end

  test 'enqueues with now implicit' do
    now = Time.utc(2018, 1, 16, 8)
    travel_to(now) do
      BillingWorker.expects(:enqueue).with(@provider, now, nil).returns(true)
      assert Finance::BillingService.async_call(@provider)
    end
  end

  test 'triggers billing' do
    Sidekiq::Testing.inline! do
      now = Time.utc(2018, 1, 16, 8)
      billing_options = { only: [@provider.id], now: now, skip_notifications: true }
      Finance::BillingStrategy.expects(:daily).with(billing_options).returns(mock_billing_success(now, @provider))
      assert Finance::BillingService.call!(@provider.id, now: now, skip_notifications: true)
    end
  end

  test 'lock remains if execution fails' do
    now = Time.utc(2018, 1, 16, 8)
    Finance::BillingStrategy.expects(:daily).raises RuntimeError, 'random failure'
    assert_raises RuntimeError do
      Finance::BillingService.call!(@provider.id, now: now)
    end
    Finance::BillingService.any_instance.expects(:report_error).with { |error| error.is_a? Finance::BillingService::LockBillingError }
    Finance::BillingService.call!(@provider.id, now: now)
  end

  # WARNING: flakiness here means a bug
  test 'lock prevents multiple jobs from running' do
    finished = false
    lock_thread = within_async_thread do
      Finance::BillingService.new(@provider.id).send(:with_lock) do
        sleep 0.1 until finished
      end
    end

    # this thread will prevent a test case deadlock by stopping the lock thread in
    # case concurrent lock sits waiting for lock to release instead of failing quick
    safety_thread = Thread.new do
      Thread.current.report_on_exception = false
      next if lock_thread.join(5)

      finished = true
      raise "billing locking causes concurrent billing jobs to wait but does not cancel them"
    end

    sleep 0.1 # make sure first thread has time to acquire the lock

    assert_raise(Finance::BillingService::LockBillingError) do
      Finance::BillingService.new(@provider.id).send(:with_lock) do
        safety_thread.join(0.001) # this will raise if thread raised so we know what actually happened
        raise "billing lock allows concurrent billing"
      end
    end
  ensure
    finished = true
  end

  class BillBuyerLevelTest < ActionDispatch::IntegrationTest
    include BillingResultsTestHelpers

    setup do
      @provider = FactoryBot.create(:provider_with_billing)
      @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    end

    teardown do
      clear_locks
    end

    test 'enqueues sidekiq worker' do
      now = Time.utc(2018, 1, 16)
      scope = @provider.buyer_accounts.where(id: @buyer_id)
      BillingWorker.expects(:enqueue).with(@provider, now, scope).returns(true)
      assert Finance::BillingService.async_call(@provider, now, scope)
    end

    test 'triggers billing' do
      Sidekiq::Testing.inline! do
        now = Time.utc(2018, 1, 16, 8)
        billing_options = { only: [@provider.id], buyer_ids: [@buyer.id], now: now, skip_notifications: true }
        Finance::BillingStrategy.expects(:daily).with(billing_options).returns(mock_billing_success(now, @provider))
        assert Finance::BillingService.call!(@buyer.id, provider_account_id: @provider.id, now: now, skip_notifications: true)
      end
    end

    test 'lock remains if execution fails' do
      now = Time.utc(2018, 1, 16, 8)
      Finance::BillingStrategy.expects(:daily).raises RuntimeError, 'random failure'
      Thread.new do
        assert_raises RuntimeError do
          Finance::BillingService.call!(@buyer.id, provider_account_id: @provider.id, now: now)
        end
      end.join
      Finance::BillingService.any_instance.expects(:report_error).with { |error| error.is_a? Finance::BillingService::LockBillingError }
      Finance::BillingService.call!(@buyer.id, provider_account_id: @provider.id, now: now)
    end

    test 'buyer locks do not affect each other' do
      buyer_2 = FactoryBot.create(:buyer_account, provider_account: @provider)
      now = Time.utc(2018, 1, 16, 8)
      Thread.new do
        assert Finance::BillingService.call!(@buyer.id, provider_account_id: @provider.id, now: now)
      end.join
      assert Finance::BillingService.call!(buyer_2.id, provider_account_id: @provider.id, now: now)
      assert_not Finance::BillingService.call!(@buyer.id, provider_account_id: @provider.id, now: now)
    end
  end

  test 'can run without lock' do
    now = '2018-01-16 08:00:00 UTC'
    Finance::BillingStrategy.expects(:daily).returns(mock_billing_success(now, @provider)).twice
    Finance::BillingService.call(@provider.id, now: now)
    Finance::BillingService.call(@provider.id, now: now)
  end
end
