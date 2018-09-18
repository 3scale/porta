# frozen_string_literal: true

require 'test_helper'

class Finance::BuyerInvoiceFinderTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryGirl.create(:simple_provider, billing_strategy: FactoryGirl.create(:postpaid_billing))
    @buyer = FactoryGirl.create(:simple_buyer, provider_account: @provider)
    @period = Month.new(Time.now)
  end

  test 'Finds the invoice when it exists' do
    period = Month.new(Time.now)
    invoice = FactoryGirl.create(:invoice, buyer_account: @buyer, provider_account: @buyer.provider_account, period: period)
    assert_equal invoice, Finance::BuyerInvoiceFinder.find(buyer: @buyer, period: @period)
    assert_equal 'manual', invoice.creation_type

    invoice = FactoryGirl.create(:invoice, buyer_account: @buyer, provider_account: @buyer.provider_account, period: period, creation_type: :background)
    assert_equal invoice, Finance::BuyerInvoiceFinder.find(buyer: @buyer, period: @period, creation_type: :background)
    assert_equal 'background', invoice.creation_type
  end

  test 'Creates an invoice if it does not find one' do
    assert_difference -> {Invoice.count} do
      invoice = Finance::BuyerInvoiceFinder.find(buyer: @buyer, period: @period)
      assert_equal @period, invoice.period
      assert_equal 'manual', invoice.creation_type
      assert_equal @buyer, invoice.buyer_account
      assert_equal @provider, invoice.provider_account

      # Idempotent
      assert_equal invoice, Finance::BuyerInvoiceFinder.find(buyer: @buyer, period: @period)
    end
  end

  test 'creates an invoice even another manually created one exists' do
    manual_invoice = FactoryGirl.create(:invoice,
                                        buyer_account: @buyer,
                                        provider_account: @buyer.provider_account,
                                        period: @period,
                                        creation_type: :manual)
    assert_difference -> {Invoice.count} do
      invoice = Finance::BuyerInvoiceFinder.find(buyer: @buyer, period: @period, creation_type: :background)
      assert_not_equal manual_invoice, invoice
    end
  end
end
