require 'test_helper'

class AccountMessengerTest < ActiveSupport::TestCase

  def setup
    @provider_account = FactoryBot.create(:provider_account,
                                :org_name => 'Foos & Bars',
                                :domain => 'foosandbars.com')
    @buyer_account = FactoryBot.create(:buyer_account,
                             :provider_account => @provider_account)
  end

  test 'expired_credit_card_notification_for_buyer' do
    AccountMessenger.any_instance.expects(:payment_url).returns("http://foo.bar")
    AccountMessenger.expired_credit_card_notification_for_buyer(@buyer_account).deliver
    message = @buyer_account.received_messages.last

    assert_equal 'Foos & Bars API - Credit card expiry', message.subject
    assert_match "Dear #{@buyer_account.org_name},", message.body
    assert_match "http://foo.bar", message.body
  end

  def url_helpers
    System::UrlHelpers.system_url_helpers
  end
end
