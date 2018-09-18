require 'test_helper'

class DetailedInvoicesByPeriodQueryTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryGirl.create(:simple_provider)
    @buyer = FactoryGirl.create(:simple_buyer, provider_account: @provider)
    @invoice_one = FactoryGirl.create(:invoice,
                                      buyer_account: @buyer,
                                      provider_account: @provider,
                                      period: Month.new(Time.utc(2009, 6, 1)),
                                      created_at: Time.utc(2009, 6, 2))
    @line_item_one = @invoice_one.line_items.create!(name: 'A', cost: 42)
    @line_item_two = @invoice_one.line_items.create!(name: 'B', cost: 58)

    @invoice_two = FactoryGirl.create(:invoice,
                                      provider_account: @provider,
                                      buyer_account: FactoryGirl.create(:simple_buyer, provider_account: @provider),
                                      period: Month.new(Time.utc(2009, 10, 1)),
                                      created_at: Time.utc(2009, 6, 1))
  end

  test '#invoices' do
    start_date = Time.utc(2009, 5, 1)
    end_date = Time.utc(2009, 7, 1)
    query = DetailedInvoicesByPeriodQuery.new(@provider, (start_date..end_date))
    assert_equal [@invoice_one], query.invoices.to_a

    end_date = Time.utc(2009, 12, 31)
    query = DetailedInvoicesByPeriodQuery.new(@provider, (start_date..end_date))
    assert_equal [@invoice_one, @invoice_two], query.invoices.to_a

    query = DetailedInvoicesByPeriodQuery.new(@provider, nil)
    assert_equal [@invoice_one, @invoice_two], query.invoices.to_a
  end

  test '#each' do
    start_date = Time.utc(2009, 5, 1)
    end_date = Time.utc(2009, 12, 31)
    query = DetailedInvoicesByPeriodQuery.new(@provider, (start_date..end_date))
    each_method = query.each

    assert_instance_of Enumerator, each_method

    invoice, line_item = each_method.next
    assert_equal @invoice_one, invoice
    assert_equal @line_item_one, line_item

    invoice, line_item = each_method.next
    assert_equal @invoice_one, invoice
    assert_equal @line_item_two, line_item

    invoice, line_item = each_method.next
    assert_equal @invoice_two, invoice
    assert line_item.new_record?

    assert_raise(::StopIteration) { each_method.next }
  end
end
