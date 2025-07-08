require 'test_helper'

class Payment::MultipleFailureCheckerTest < ActiveSupport::TestCase
  test 'suspends the account and revoke session if too many errors' do
    account = FactoryBot.create(:simple_buyer)
    mocked_session.expects(:revoke!)
    service = Payment::MultipleFailureChecker.new(account, false, mocked_session)
    9.times { service.call }

    service.call

    account.reload
    assert account.suspended?
  end

  test 'should not suspend the account if failures is below the threshold' do
    account = FactoryBot.create(:simple_buyer)
    service = Payment::MultipleFailureChecker.new(account, false, mocked_session)

    5.times { service.call }

    service.call

    account.reload
    refute account.suspended?
  end

  private

  def mocked_session
    @mocked_session ||= stub(:user_session)
  end
end
