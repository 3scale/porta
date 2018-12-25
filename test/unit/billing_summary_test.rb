# frozen_string_literal: true

require 'test_helper'

class BillingSummaryTest < ActiveSupport::TestCase
  include BillingResultsTestHelpers

  setup do
    @billing_summary = BillingSummary.new('random-batch-id')
  end

  test 'store successes' do
    @billing_summary.expects(:summary_key).returns('my-key').times(5)

    assert @billing_summary.store('buyer-1', { success: true, errors: [] })
    assert @billing_summary.store('buyer-2', { success: true, errors: [] })
    assert @billing_summary.store('buyer-3', { success: true, errors: [] })

    stored_summary = { success: true, skip: false, errors: [] }
    assert_equal stored_summary, @billing_summary.to_hash
  end

  test 'store with skips' do
    @billing_summary.expects(:summary_key).returns('my-key').times(5)

    assert @billing_summary.store('1', { success: true, errors: [] })
    assert @billing_summary.store('2', { success: false, skip: true, errors: [] })
    assert @billing_summary.store('3', { success: true, errors: [] })

    stored_summary = { success: true, skip: true, errors: [] }
    assert_equal stored_summary, @billing_summary.to_hash
  end

  test 'store with errors' do
    @billing_summary.expects(:summary_key).returns('my-key').times(7)

    assert @billing_summary.store('1', { success: true, errors: [] })
    assert @billing_summary.store('2', { success: true, errors: [] })
    assert @billing_summary.store('3', { success: false, errors: [3] })
    assert @billing_summary.store('4', { success: true, errors: [] })
    assert @billing_summary.store('5', { success: false, errors: [5] })

    stored_summary = { success: false, skip: false, errors: [3, 5] }
    assert_equal stored_summary, @billing_summary.to_hash
  end

  test 'unstore' do
    @billing_summary.stubs(summary_key: 'my-key')
    @billing_summary.store(1, { success: false, errors: [3] })
    assert_equal 1, @billing_summary.redis.zcard('my-key')
    @billing_summary.unstore
    assert_equal 0, @billing_summary.redis.zcard('my-key')
  end

  test 'build billing result' do
    provider = FactoryBot.create(:provider_with_billing)
    billing_date = Time.utc(2018, 2, 5)

    billing_success = mock_billing_success(billing_date, provider)
    @billing_summary.store('1', billing_success[provider.id])

    billing_failure = mock_billing_failure(billing_date, provider, [2])
    @billing_summary.store('2', billing_failure[provider.id])

    result = @billing_summary.build_result(provider.id, billing_date)

    stored_summary = { success: false, skip: false, errors: [2] }
    assert_equal billing_date, result.period
    assert_equal stored_summary, result[provider.id]
  end
end
