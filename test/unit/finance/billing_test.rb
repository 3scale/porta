require 'test_helper'

class BillingTest < ActiveSupport::TestCase

  def setup
    provider = FactoryBot.create(:simple_provider)
    buyer = FactoryBot.create(:simple_buyer, :provider_account => provider)

    @invoice = FactoryBot.create(:invoice,
                              :period => Month.new(Time.zone.local(1984, 1, 1)),
                              :provider_account => provider,
                              :buyer_account => buyer,
                              :friendly_id => '0000-00-00000001')
    @billing_invoice = Finance::AdminBilling.new(@invoice)

    @item = { name: 'FakeName', cost: 22, type: LineItem::PlanCost }
  end

  test '#create_line_item creates successfully' do
    @billing_invoice.create_line_item(@item)
    assert_equal 1, @invoice.line_items.count
  end

  test '#create_line_item creates with the right attributes' do
    @billing_invoice.create_line_item(@item)
    assert_equal @item[:type], @invoice.line_items.last.class
    assert_equal @item[:name], @invoice.line_items.last.name
    assert_equal @item[:cost], @invoice.line_items.last.cost
  end

  test '#create_line_item returns error in the model when the invoice shouldn\'t allow to add line_items' do
    @invoice.update_attribute(:state, 'pending')
    @line_item = @billing_invoice.create_line_item(@item)
    assert_equal 0, @invoice.line_items.count
    assert_includes @line_item.errors.full_messages, 'Invalid invoice state'
  end

  test '#create_line_item! creates successfully' do
    @billing_invoice.create_line_item!(@item)
    assert_equal 1, @invoice.line_items.count
  end

  test '#create_line_item! creates with the right attributes' do
    @billing_invoice.create_line_item!(@item)
    assert_equal @item[:type], @invoice.line_items.last.class
    assert_equal @item[:name], @invoice.line_items.last.name
    assert_equal @item[:cost], @invoice.line_items.last.cost
  end

  test '#create_line_item! raises exception when the invoice shouldn\'t allow to add line_items' do
    @invoice.update_attribute(:state, 'pending')
    assert_raise Invoice::InvalidInvoiceStateException do
      @line_item = @billing_invoice.create_line_item!(@item)
    end
    assert_equal 0, @invoice.line_items.count
  end

  test '#destroy_line_item works' do
    line_item = FactoryBot.create(:line_item, invoice: @invoice)
    assert_difference LineItem.method(:count), -1 do
      @billing_invoice.destroy_line_item(line_item)
    end
  end

  test '#destroy_line_item returns error when the invoice shouldn\'t allow to destroy line_items' do
    line_item = FactoryBot.create(:line_item, invoice: @invoice)
    @invoice.update_attribute(:state, 'pending')
    @billing_invoice.destroy_line_item(line_item)
    assert_equal true, line_item.persisted?
    assert_includes line_item.errors[:base], 'Invalid invoice state'
  end

  test '#destroy_line_item raises error when the @invoice is not the same as line_item.invoice' do
    line_item = FactoryBot.create(:line_item, invoice: FactoryBot.create(:invoice))
    assert_raise ActiveRecord::RecordNotFound do
      @billing_invoice.destroy_line_item(line_item)
    end
    assert_equal true, line_item.persisted?
  end

  test '#bill bills when its with admin billing and should_bill? would return false' do
    @billing_invoice = Finance::AdminBilling.new(@invoice)
    @yields_block = false
    Invoice.any_instance.stubs(:should_bill?).returns(false)
    @billing_invoice.send(:bill) { @yields_block = true }
    assert @yields_block
  end

  test '#bill bills when its with admin billing and should_bill? returns true' do
    @billing_invoice = Finance::AdminBilling.new(@invoice)
    @yields_block = false
    Invoice.any_instance.stubs(:should_bill?).returns(true)
    @billing_invoice.send(:bill) { @yields_block = true }
    assert @yields_block
  end

  test '#bill bills when its with background billing and should_bill? returns true' do
    @billing_invoice = Finance::BackgroundBilling.new(@invoice)
    @yields_block = false
    Invoice.any_instance.stubs(:should_bill?).returns(true)
    @billing_invoice.send(:bill) { @yields_block = true }
    assert @yields_block
  end

  test '#bill does not bill when its background and should_bill? return false' do
    @billing_invoice = Finance::BackgroundBilling.new(@invoice)
    @yields_block = false
    Invoice.any_instance.stubs(:should_bill?).returns(false)
    @billing_invoice.send(:bill) { @yields_block = true }
    assert_equal false, @yields_block
  end

  test '#bill raises NotImplementedError when it is called without being implemented in a subclass' do
    @billing_invoice = Finance::Billing.new(@invoice)
    assert_raise NotImplementedError, '\'bill\' must be implemented in subclasses of Billing' do
      @yields_block = false
      @billing_invoice.send(:bill) { @yields_block = true }
    end
  end

end
