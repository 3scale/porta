require 'test_helper'

class AccountMessengerTest < ActiveSupport::TestCase

  def setup
    @provider_account = Factory(:provider_account,
                                :org_name => 'Foos & Bars',
                                :domain => 'foosandbars.com')
    @buyer_account = Factory(:buyer_account,
                             :provider_account => @provider_account)
  end

  test 'invoices to review for provider' do
    AccountMessenger.invoices_to_review( @provider_account ).deliver

    message = @provider_account.received_messages.last
    assert_match url_helpers.admin_finance_invoices_url(host: @provider_account.self_domain, state: :finalized), message.body
  end

  test 'expired_credit_card_notification_for_buyer' do
    AccountMessenger.any_instance.expects(:payment_url).returns("http://foo.bar")
    AccountMessenger.expired_credit_card_notification_for_buyer(@buyer_account).deliver
    message = @buyer_account.received_messages.last

    assert_equal 'Foos & Bars API - Credit card expiry', message.subject
    assert_match "Dear #{@buyer_account.org_name},", message.body
    assert_match "http://foo.bar", message.body
  end

  test 'expired_credit_card_notification_for_provider' do
    AccountMessenger.expired_credit_card_notification_for_provider(@buyer_account).deliver
    message = @provider_account.received_messages.last

    assert_equal 'API System: User Credit card expiry', message.subject
    assert_match "Dear #{@provider_account.org_name},", message.body
    assert_match "for user #{@buyer_account.org_name} is about", message.body
  end

  test 'new signup with required approval' do
    @buyer_account.buy! Factory(:account_plan, :approval_required => true)
    AccountMessenger.new_signup(@buyer_account).deliver
    message = @provider_account.received_messages.last

    assert_equal 'API System: New Account Signup', message.subject
    assert_match "Dear API Administrator", message.body
    assert_match "new user #{@buyer_account.admins.first.username} has signed up.", message.body
    assert_match "user requires your approval before keys can be used", message.body
  end

  test 'new signup without required approval' do
    @buyer_account.buy! Factory(:account_plan, :approval_required => false)
    AccountMessenger.new_signup(@buyer_account).deliver
    message = @provider_account.received_messages.last

    refute_match /user requires your approval before keys can be used/, message.body
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
