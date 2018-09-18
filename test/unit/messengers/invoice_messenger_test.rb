require 'test_helper'

class InvoiceMessengerTest < ActiveSupport::TestCase

  def setup
    @provider = Factory(:provider_with_billing,
                        org_name: 'foos & bars',
                        payment_gateway_type: 'braintree_blue')
    @provider.billing_strategy.update_attribute(:currency, 'EUR')
    @buyer = Factory(:buyer_account, provider_account: @provider, org_name: 'DEVELOPER')

    @invoice = Factory(:invoice, buyer_account: @buyer, provider_account: @provider)
  end

  test 'upcoming_charge_notification' do
    items = [ stub('line item', cost: 128, name: 'foo') ]
    items.stubs(:sum).returns(128)
    @invoice.stubs(:line_items).returns(items)

    InvoiceMessenger.upcoming_charge_notification(@invoice).deliver

    message = @buyer.received_messages.last
    assert_equal 'foos & bars API - Monthly statement', message.subject
    assert_match "Dear DEVELOPER,", message.body
    assert_match /EUR 128\.00/, message.body
  end

  test 'url for provider invoices is on their own domain' do
    master_invoice = Factory(:invoice, buyer_account: @provider, provider_account: Account.master)

    InvoiceMessenger.upcoming_charge_notification(master_invoice).deliver

    message = @provider.received_messages.last
    assert_match @provider.self_domain, message.body
    assert_match %r{http://.*/p/admin/account/invoices/\d+}, message.body
  end

  test 'failed_charge_notification_for_buyer first attempt' do
    InvoiceMessenger.unsuccessfully_charged_for_buyer(@invoice).deliver
    message = @buyer.received_messages.last

    assert_equal 'foos & bars API - Problem with payment', message.subject
    assert_match "Dear DEVELOPER,", message.body
  end

  test 'failed_charge_notification_for_buyer final attempt' do
    InvoiceMessenger.unsuccessfully_charged_for_buyer_final(@invoice).deliver

    expected = <<-MSG
Dear DEVELOPER,

This is to notify you that your last credit card payment failed and we have been unable to charge the outstanding amount. Please contact us at #{@buyer.provider_account.finance_support_email} in order to resolve the situation; failure to do so may result in service access being disabled for your account.

MSG

    message = @buyer.received_messages.last
    assert_equal 'foos & bars API - Problem with payment', message.subject
    assert_match expected, message.body
  end

  test 'send invoice to providers from master' do
    Account.master.update_attribute(:payment_gateway_type, 'braintree_blue')
    invoice  = Factory :invoice, provider_account: Account.master, buyer_account: @provider
    InvoiceMessenger.unsuccessfully_charged_for_buyer(invoice).deliver

    message = Message.last

    assert_match "/p/admin/account/braintree_blue", message.body
  end

  test 'send invoice to buyers from provider' do
    buyer    = Factory :buyer_account, provider_account: @provider
    invoice  = Factory :invoice, provider_account: @provider, buyer_account: buyer

    InvoiceMessenger.unsuccessfully_charged_for_buyer(invoice).deliver

    message = Message.last
    assert_not_match "/p/admin/account/braintree_blue", message.body
    assert_match "/admin/account/braintree_blue", message.body
  end

end
