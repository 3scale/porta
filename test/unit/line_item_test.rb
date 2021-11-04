require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  should belong_to :invoice

  setup do
    master_account.try(:delete)
    master_account
  end

  test 'returns cost in currency of the billing strategy' do
    provider_account_one = FactoryBot.create(:provider_with_billing)
    provider_account_two = FactoryBot.create(:provider_with_billing)

    provider_account_one.billing_strategy.update_attribute(:currency, 'EUR')
    provider_account_two.billing_strategy.update_attribute(:currency, 'USD')

    invoice_one = FactoryBot.create(:invoice, :provider_account => provider_account_one)
    invoice_two = FactoryBot.create(:invoice, :provider_account => provider_account_two)

    line_item_one = invoice_one.line_items.new(:cost => 10)
    line_item_two = invoice_two.line_items.new(:cost => 42)

    assert_equal 'EUR', line_item_one.cost.currency
    assert_equal 'USD', line_item_two.cost.currency
  end

  test 'sum_by_invoice_state' do
    assert_equal 0, LineItem.sum_by_invoice_state(:finalized)
    assert_equal 0, LineItem.sum_by_invoice_state('finalized')
  end

  context 'LineItem' do
    setup do
      @line_item = FactoryBot.create(:line_item_plan_cost)
    end


    should 'respond to #to_xml' do
      # TODO: add content assertioins
      assert_not_nil @line_item.to_xml
    end
  end

  test 'plan_id' do
    line_item = LineItem.new
    contract = Contract.new

    contract.plan_id = 6
    line_item.contract = contract

    assert_equal 6, line_item.plan_id

    line_item.plan_id = 8
    assert_equal 8, line_item.plan_id
  end

  test 'audited' do
    invoice = FactoryBot.create :invoice

    LineItem.with_synchronous_auditing do
      item = invoice.line_items.create!(name: 'Item #1', cost: 10.0, quantity: 1)
      audit = invoice.associated_audits.last
      assert_equal 'create', audit.action
      assert_equal item, audit.auditable

      item.destroy!
      audit = invoice.associated_audits.last
      assert_equal 'destroy', audit.action
      assert_equal item.id, audit.auditable_id
      assert_equal 'LineItem', audit.auditable_type
    end
  end


  test 'type is a String' do
    assert_equal '', LineItem.new.type
  end

end
