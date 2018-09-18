require 'test_helper'

class Finance::InvoiceProxyTest < ActiveSupport::TestCase

  def setup
    @account = FactoryGirl.create(:provider_with_billing)
    buyer = FactoryGirl.build_stubbed(:buyer_account, provider_account: @account)
    @month = Month.new(Time.zone.now)
    @proxy = Finance::InvoiceProxy.new(buyer, @month)
    @item = stub('item', :name => 'name', :cost => 43)
    @invoice = mock('invoice')
    @invoice.expects(:line_items).returns([])
  end

  test 'when invoice exists, delegate calls to it' do
    Finance::BuyerInvoiceFinder.expects(:find).returns(@invoice)
    assert_equal 0, @proxy.line_items.count
  end

  test 'when no invoice exist, create a new invoice' do
    @account.billing_strategy.expects(:create_invoice!).returns(@invoice)
    assert_equal 0, @proxy.line_items.count
  end
end
