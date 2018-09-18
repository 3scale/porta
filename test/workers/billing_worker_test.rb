# frozen_string_literal: true

require 'test_helper'

class BillingWorkerTest < ActiveSupport::TestCase
  include BillingResultsTestHelpers

  setup do
    @provider = FactoryGirl.create(:provider_with_billing)
    @buyer = FactoryGirl.create(:buyer_account, provider_account: @provider)
  end

  test 'perform' do
    time = Time.utc(2017, 12, 1, 8, 0)

    billing_options = { only: [@provider.id], buyer_ids: [@buyer.id], now: time, skip_notifications: true }
    Finance::BillingStrategy.expects(:daily).with(billing_options).returns(mock_billing_success(time, @provider))
    assert BillingWorker.new.perform(@buyer.id, @provider.id, time.to_s(:iso8601))
  end

  test 'creates a lock per buyer account' do
    time = Time.utc(2017, 12, 1, 8, 0)

    assert_difference BillingLock.method(:count) do
      billing_options = { only: [@provider.id], buyer_ids: [@buyer.id], now: time, skip_notifications: true }
      Finance::BillingStrategy.expects(:daily).with(billing_options).returns(mock_billing_success(time, @provider))
      BillingLock.expects(:delete).with(@buyer.id).returns(false)
      BillingWorker.new.perform(@buyer.id, @provider.id, time.to_s(:iso8601))
    end
  end

  test 'aborts if buyer is locked' do
    time = Time.utc(2017, 12, 1, 8, 0)

    BillingLock.create!(account_id: @buyer.id)
    refute BillingWorker.new.perform(@buyer.id, @provider.id, time.to_s(:iso8601))
  end

  test 'callback' do
    time = Time.utc(2017, 12, 1, 8, 0)

    Sidekiq::Testing.inline! do
      batch = Sidekiq::Batch.new
      callback_options = { batch_id: batch.bid, account_id: @provider.id, billing_date: time }
      batch.on(:complete, BillingWorker::Callback, callback_options)
      batch.jobs do
        BillingWorker.perform_async(@buyer.id, @provider.id, time)
      end

      Finance::BillingService.any_instance.expects(:notify_billing_finished).returns(true)
      Sidekiq::Batch::Status.any_instance.expects(:delete).returns(true)

      assert BillingWorker::Callback.new.on_complete(Sidekiq::Batch::Status.new(batch.bid), callback_options.stringify_keys)
    end
  end
end
