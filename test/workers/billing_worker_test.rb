# frozen_string_literal: true

require 'test_helper'

class BillingWorkerTest < ActiveSupport::TestCase
  include BillingResultsTestHelpers

  setup do
    @provider = FactoryBot.create(:provider_with_billing)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
  end

  def teardown
    clear_sidekiq_lock
  end

  test 'perform' do
    time = Time.utc(2017, 12, 1, 8, 0)

    billing_options = { only: [@provider.id], buyer_ids: [@buyer.id], now: time, skip_notifications: true }
    Finance::BillingStrategy.expects(:daily).with(billing_options).returns(mock_billing_success(time, @provider))
    assert BillingWorker.new.perform(@buyer.id, @provider.id, time.to_s(:iso8601), false)
  end

  test 'creates a lock per buyer account' do
    time = Time.utc(2017, 12, 1, 8, 0)

    assert_difference BillingLock.method(:count) do
      billing_options = { only: [@provider.id], buyer_ids: [@buyer.id], now: time, skip_notifications: true }
      Finance::BillingStrategy.expects(:daily).with(billing_options).returns(mock_billing_success(time, @provider))
      BillingLock.expects(:delete).with(@buyer.id).returns(false)
      BillingWorker.new.perform(@buyer.id, @provider.id, time.to_s(:iso8601), false)
    end
  end

  test 'aborts if buyer is locked' do
    time = Time.utc(2017, 12, 1, 8, 0)

    BillingLock.create!(account_id: @buyer.id)
    refute BillingWorker.new.perform(@buyer.id, @provider.id, time.to_s(:iso8601), false)
  end

  test 'callback' do
    time = Time.utc(2017, 12, 1, 8, 0)

    Sidekiq::Testing.inline! do
      batch = Sidekiq::Batch.new
      callback_options = { batch_id: batch.bid, account_id: @provider.id, billing_date: time }
      batch.on(:complete, BillingWorker::Callback, callback_options)
      batch.jobs do
        BillingWorker.perform_async(@buyer.id, @provider.id, time, false)
      end

      Finance::BillingService.any_instance.expects(:notify_billing_finished).returns(true)
      Sidekiq::Batch::Status.any_instance.expects(:delete).returns(true)

      assert BillingWorker::Callback.new.on_complete(Sidekiq::Batch::Status.new(batch.bid), callback_options.stringify_keys)
    end
  end

  test 'lock_name' do
    assert_equal 'billing::provider:123', BillingWorker.lock_name(nil, 123)
  end

  test 'enqueues checks whether lock is needed' do
    time = Time.utc(2019, 1, 1, 8, 0)

    gateway = mock(need_lock?: true, need_sparsing?: false)
    PaymentGateway.expects(:find).returns(gateway)
    BillingWorker.expects(:enqueue_for_buyer).once.with(@buyer, time, needs_lock: true)
    assert BillingWorker.enqueue(@provider, time)

    gateway = mock(need_lock?: false, need_sparsing?: false)
    PaymentGateway.expects(:find).returns(gateway)
    BillingWorker.expects(:enqueue_for_buyer).once.with(@buyer, time, needs_lock: false)
    assert BillingWorker.enqueue(@provider, time)
  end

  test 'perform acquires a lock' do
    time = Time.utc(2017, 12, 1, 8, 0)
    job_options = [@buyer.id, @provider.id, time, true]
    billing_options = [@buyer.id, { provider_account_id: @provider.id, now: time, skip_notifications: true }]

    job = BillingWorker.new
    job.expects(:lock).twice.returns(mock acquire!: true, release!: true)
    Finance::BillingService.expects(:call!).with(*billing_options)
    job.perform(*job_options)
  end

  test 'perform reschedules if it fails to acquire the lock' do
    time = Time.utc(2017, 12, 1, 8, 0)
    job_options = [@buyer.id, @provider.id, time, true]
    billing_options = [@buyer.id, { provider_account_id: @provider.id, now: time, skip_notifications: true }]

    job = BillingWorker.new
    job.expects(:lock).once.returns(mock acquire!: false)
    Finance::BillingService.expects(:call!).with(*billing_options).never
    BillingWorker::LockError.expects(:new)
    BillingWorker.expects(:perform_async).with(*job_options)
    job.perform(*job_options)
  end

  test 'perform ignores the lock when not needed' do
    time = Time.utc(2017, 12, 1, 8, 0)
    job_options = [@buyer.id, @provider.id, time, false]
    billing_options = [@buyer.id, { provider_account_id: @provider.id, now: time, skip_notifications: true }]

    job = BillingWorker.new
    job.expects(:lock).never
    Finance::BillingService.expects(:call!).with(*billing_options)
    job.perform(*job_options)
  end

  test 'lock is scoped per provider' do
    lock1 = lock2 = lock3 = nil

    f1 = Fiber.new { lock1 = BillingWorker.new.lock(nil, 1).acquire! }
    f2 = Fiber.new { lock2 = BillingWorker.new.lock(nil, 1).acquire! }
    f3 = Fiber.new { lock3 = BillingWorker.new.lock(nil, 2).acquire! }

    f1.resume
    f2.resume
    f3.resume

    assert lock1
    refute lock2
    assert lock3
  end

  test 'jobs get rescheduled when provider is locked' do
    job_options = [@buyer.id, @provider.id, time, true]
    lock = set_sidekiq_lock(BillingWorker, job_options)
    lock.expects(:acquire!).returns(false)
    BillingWorker::LockError.expects(:new)
    BillingWorker.expects(:perform_async).with(*job_options)
    BillingWorker.new.perform(*job_options)
  end

  test '#enqueue_for_buyer accepts a delay' do
    time = Time.utc(2019, 1, 15, 8, 0)
    BillingWorker.expects(:perform_in).with(5.seconds, @buyer.id, @provider.id, time.to_s(:iso8601), false)
    BillingWorker.enqueue_for_buyer(@buyer, time, delay: 5.seconds)

    BillingWorker.expects(:perform_in).with(0.second, @buyer.id, @provider.id, time.to_s(:iso8601), false)
    BillingWorker.enqueue_for_buyer(@buyer, time)
  end

  test 'enqueue sparses jobs in time' do
    time = Time.utc(2019, 1, 15, 8, 0)

    FactoryBot.create_list(:buyer_account, 10, provider_account: @provider)
    BillingWorker.stubs(sparsing_rate: 0.5)
    PaymentGateway.expects(:find).returns(mock(need_lock?: false, need_sparsing?: true))

    @provider.buyer_accounts.each_with_index { |buyer, index| BillingWorker.expects(:enqueue_for_buyer).with(buyer, time, needs_lock:  false, delay: 0.5*index) }
    BillingWorker.enqueue(@provider, time)
  end
end
