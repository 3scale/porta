require 'test_helper'

class Payment::SpamProtectionServiceTest < ActiveSupport::TestCase
  test 'should not increment the failure count for the account if payment was successful' do
    account = FactoryBot.create(:simple_account, payment_gateway_options: {failure_count: 0})
    service = Payment::SpamProtectionService.new(account, true, mocked_session)

    service.call

    account.reload
    refute account.suspended?
    assert account.gateway_setting.failure_count.zero?
  end

  test 'increment the failure count for the account if payment was not successful' do
    account = FactoryBot.create(:simple_account, payment_gateway_options: {failure_count: 0})
    service = Payment::SpamProtectionService.new(account, false, mocked_session)

    service.call

    account.reload
    refute account.suspended?
    assert_equal 1, account.gateway_setting.failure_count
  end

  test 'suspends the account and revoke session if failure_count is higher than the threshold' do
    account = FactoryBot.create(:simple_account, payment_gateway_options: {failure_count: PaymentGatewaySetting::FAILURE_THRESHOLD + 1})
    mocked_session.expects(:revoke!)
    service = Payment::SpamProtectionService.new(account, false, mocked_session)

    service.call

    account.reload
    assert account.suspended?
  end

  test 'should not suspend the account if failure_count is below the threshold' do
    account = FactoryBot.create(:simple_account, payment_gateway_options: {failure_count: PaymentGatewaySetting::FAILURE_THRESHOLD - 1})
    service = Payment::SpamProtectionService.new(account, false, mocked_session)

    service.call

    account.reload
    refute account.suspended?
  end

  test '#spamming? returns true if have more than 10 requests in an hour' do
    account = FactoryBot.create(:simple_account, payment_gateway_options: {failure_count: PaymentGatewaySetting::FAILURE_THRESHOLD - 1})
    service = Payment::SpamProtectionService.new(account, true, mocked_session)

    11.times { service.call }

    assert service.spamming?
  end

  private

  def mocked_session
    @mocked_session ||= stub(:user_session)
  end
end
