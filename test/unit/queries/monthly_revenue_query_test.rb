require 'test_helper'

class MonthlyRevenueQueryTest < ActiveSupport::TestCase

  def setup
    Timecop.return
    @provider = FactoryGirl.create(:simple_provider)
    @buyer = FactoryGirl.create(:simple_buyer, provider_account: @provider)

    @invoice_one = FactoryGirl.create(:invoice,
                                      buyer_account: @buyer,
                                      provider_account: @provider,
                                      period: Month.new(Time.utc(2009, 6, 1)),
                                      created_at: Time.utc(2009, 6, 2))

    @invoice_two = FactoryGirl.create(:invoice,
                                      provider_account: @provider,
                                      buyer_account: FactoryGirl.create(:simple_buyer, provider_account: @provider),
                                      period: Month.new(Time.utc(1964, 10, 1)),
                                      created_at: Time.utc(2009, 6, 1))

    @invoice_one.line_items.create!(name: 'A', cost: 42)
    @invoice_one.line_items.create!(name: 'B', cost: 58)

    @query = MonthlyRevenueQuery.new(@provider)
  end

  test '#with_states' do
    pay_invoice(@invoice_one)
    pay_invoice(@invoice_two)
    common_group_costs_by_period_assertions
  end

  test '#with_states is not confused by period vs created_at ordering' do
    @invoice_one.update_attribute(:created_at, Time.utc(2009, 6, 1))
    @invoice_two.update_attribute(:created_at, Time.utc(2009, 6, 2))
    pay_invoice(@invoice_one)
    pay_invoice(@invoice_two)
    common_group_costs_by_period_assertions
  end

  test '#with_states includes deleted buyers' do
    # Try to destroy buyer of @invoice_one
    @buyer.delete

    groups = @query.with_states

    assert_equal 2, groups.size
    assert_equal 100, groups.first.total_cost
  end

  test '#with_states respects VAT' do
    @invoice_one.buyer_account.update_attribute(:vat_rate, 100)
    pay_invoice(@invoice_one)

    groups = @query.with_states
    assert_equal 200, groups.first.total_cost

    @invoice_one.buyer_account.update_attribute(:vat_rate, 200)
    groups = @query.with_states
    assert_equal 200, groups.first.total_cost

    @query = MonthlyRevenueQuery.new(@provider, include_vat: false)
    groups = @query.with_states
    assert_equal 100, groups.first.total_cost
  end

  test 'with_states does not include cancelled invoices' do
    trap = FactoryGirl.create(:invoice, period: @invoice_one.period,
                              provider_account: @provider, buyer_account: @buyer)
    trap.line_items.create!(name: 'C', cost: 11)
    trap.cancel!

    pay_invoice(@invoice_one)
    pay_invoice(@invoice_two)

    groups = @query.with_states

    assert_equal 2, groups.size
    assert_equal 100, groups.first.total_cost
  end

  test '#with_states groups by state' do
    @invoice_three = FactoryGirl.create(:invoice,
                                        buyer_account: @buyer,
                                        provider_account: @provider,
                                        period: Month.new(Time.utc(2009, 6, 1)),
                                        created_at: Time.utc(2009, 6, 2))

    @invoice_two.line_items.create!(name: 'C', cost: 15)
    @invoice_three.line_items.create!(name: 'D', cost: 1237)

    pay_invoice(@invoice_one)
    @invoice_three.issue_and_pay_if_free!
    @invoice_three.mark_as_unpaid!

    groups = @query.with_states

    assert_equal 2, groups.size
    assert_equal 1337, groups.first.total_cost
    assert_equal 1237, groups.first.overdue_cost
    assert_equal 100, groups.first.paid_cost
    assert_equal 15, groups.last.in_process_cost
  end

  private

  def common_group_costs_by_period_assertions
    groups = @query.with_states
    assert_equal 2, groups.size
    assert_equal 100, groups.first.total_cost, groups.map(&:total_cost).to_sentence
    assert_equal 0,   groups.last.total_cost, groups.map(&:total_cost).to_sentence
  end

  def pay_invoice(invoice)
    invoice.finalize
    invoice.issue
    invoice.pay
  end
end
