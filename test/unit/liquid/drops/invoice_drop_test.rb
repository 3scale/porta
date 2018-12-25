require 'test_helper'

class Liquid::Drops::InvoiceDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @invoice =  FactoryBot.build_stubbed(:invoice)
    @drop = Drops::Invoice.new(@invoice)
  end


  should 'return url' do
    @invoice.stubs id: 22
    assert_equal "/admin/account/invoices/22", @drop.url
  end

  should 'return pdf_url' do
    @invoice.stub_chain(:pdf, :expiring_url).returns('http://example.com/pdf')
    assert_equal 'http://example.com/pdf', @drop.pdf_url
  end

  should 'return friendly_id' do
    assert_equal @invoice.friendly_id, @drop.friendly_id
  end

  should 'return name' do
    assert_equal @invoice.name, @drop.name
  end

  should 'return state' do
    assert_equal @invoice.state, @drop.state
  end

  should 'return 0.00' do
    @invoice.stubs cost: ThreeScale::Money.new(0.0, 'EUR')
    assert_equal '0.00', @drop.cost
  end

  should 'return cost' do
    @invoice.stubs cost: ThreeScale::Money.new(23.34, 'EUR')
    assert_equal '23.34', @drop.cost.to_s
  end

  # Regression test for: https://github.com/3scale/system/issues/2508
  should 'returns negative costs' do
    @invoice.stubs cost: ThreeScale::Money.new(-42.24, 'EUR')
    assert_equal '-42.24', @drop.cost.to_s
  end


  should 'true if pdf exists' do
    @invoice.stub_chain(:pdf, :file?).returns(true)
    assert @drop.exists_pdf?
  end

  should 'false unless pdf exists' do
    @invoice.stub_chain(:pdf, :file?).returns(false)
    assert !@drop.exists_pdf?
  end

  should 'return period_begin' do
    assert_equal @invoice.period.begin, @drop.period_begin
  end

  should 'return perdiod_end' do
    assert_equal @invoice.period.end, @drop.period_end
  end

  should 'return due_on' do
    assert_equal @invoice.due_on, @drop.due_on
  end

  should 'return paid_on' do
    assert_equal @invoice.paid_at, @drop.paid_on
  end

  should 'return vat_code' do
    assert_equal @invoice.vat_code, @drop.vat_code
  end

  should 'return fiscal_code' do
    assert_equal @invoice.fiscal_code, @drop.fiscal_code
  end

  should 'return buyer_account' do
    assert_kind_of Liquid::Drops::Account, @drop.buyer_account
    assert_equal @invoice.buyer_account.id, @drop.buyer_account.id
  end

  should 'returns cost_without_vat' do
    assert_equal '0.00', @drop.cost_without_vat
  end

  should 'returns vat_amount' do
    assert_equal '0.00', @drop.vat_amount
  end

  should 'returns vat_rate' do
    assert_nil @drop.vat_rate
  end

  should 'returns payment_transactions' do
    FactoryBot.create(:payment_transaction, invoice: @invoice)

    assert_kind_of Liquid::Drops::Collection, @drop.payment_transactions
    assert_equal @drop.payment_transactions.count, @invoice.payment_transactions.count
    assert_kind_of Liquid::Drops::PaymentTransaction, @drop.payment_transactions[0]
  end
end
