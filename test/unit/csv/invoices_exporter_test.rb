require 'test_helper'

class Csv::InvoicesExporterTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  def setup
    @provider = FactoryGirl.create(:simple_provider, org_name: 'FunkyTech', domain: 'funky-tech.com')
    @buyer = FactoryGirl.create(:simple_buyer, provider_account: @provider, org_legaladdress: 'Null street')

    @invoice_one = FactoryGirl.create(:invoice,
                                      buyer_account: @buyer,
                                      provider_account: @provider,
                                      period: Month.new(Time.utc(2009, 6, 1)),
                                      created_at: Time.utc(2009, 6, 2))

    @buyer2 =  FactoryGirl.create(:simple_buyer, provider_account: @provider)
    @invoice_two = FactoryGirl.create(:invoice,
                                      provider_account: @provider,
                                      buyer_account: @buyer2,
                                      period: Month.new(Time.utc(1964, 10, 1)),
                                      created_at: Time.utc(2009, 6, 1))

    @line_item_one = @invoice_one.line_items.create!(name: 'A', cost: 42, description: 'hello')
    @line_item_two = @invoice_one.line_items.create!(name: 'B', cost: 58, description: 'world')
    @line_item_one.type = 'LineItem::PlanCost'
    @line_item_two.type = ''
    @line_item_one.save!
    @line_item_two.save!
  end

  test '#to_csv' do
    Timecop.freeze(Time.utc(2009, 6, 25)) do
      exporter = Csv::InvoicesExporter.new(@provider, period: 'this_month', data: 'invoices')
      csv = exporter.to_csv
      lines = csv.lines.map(&:strip)
      assert_equal 'FunkyTech/funky-tech.com - All Invoices / period from 2009-06-01 to #2009-06-30', lines[0]
      assert_equal '', lines[1]

      assert_equal 'Invoice Id,Invoice Friendly Id,Invoice State,Paid At,Due On,Issued On,Currency,Invoice Cost,From,To,Account Id,Organization Name,Address,City,State,Country,Zip Code,Invoice Line Id,Name,Description,Quantity,Type,Invoice Line Cost', lines[2]

      address = @buyer.billing_address

      data1 = [
        @invoice_one.id, @invoice_one.friendly_id, @invoice_one.state, @invoice_one.paid_at, @invoice_one.due_on, @invoice_one.issued_on, @invoice_one.currency, @invoice_one.cost, @invoice_one.period.begin, @invoice_one.period.end,
        @buyer.id, @buyer.org_name, address.address1, address.city, address.state, address.country, address.zip,
        @line_item_one.id, @line_item_one.name, @line_item_one.description, @line_item_one.quantity, @line_item_one.type, @line_item_one.cost
      ]
      assert_equal data1.join(','), lines[3]


      data2 = [
        @invoice_one.id, @invoice_one.friendly_id, @invoice_one.state, @invoice_one.paid_at, @invoice_one.due_on, @invoice_one.issued_on, @invoice_one.currency, @invoice_one.cost, @invoice_one.period.begin, @invoice_one.period.end,
        @buyer.id, @buyer.org_name, address.address1, address.city, address.state, address.country, address.zip,
        @line_item_two.id, @line_item_two.name, @line_item_two.description, @line_item_two.quantity, '""', @line_item_two.cost
      ]
      assert_equal data2.join(','), lines[4]
    end

    Timecop.freeze(Time.utc(1964, 12, 25)) do
      exporter = Csv::InvoicesExporter.new(@provider, period: 'this_year', data: 'invoices')
      csv = exporter.to_csv
      lines = csv.lines.map(&:strip)
      address = @buyer2.billing_address

      assert_equal 'FunkyTech/funky-tech.com - All Invoices / period from 1964-01-01 to #1964-12-31', lines[0]

      data = [
        @invoice_two.id, @invoice_two.friendly_id, @invoice_two.state, @invoice_two.paid_at, @invoice_two.due_on, @invoice_two.issued_on, @invoice_two.currency, @invoice_two.cost, @invoice_two.period.begin, @invoice_two.period.end,
        @buyer2.id, @buyer2.org_name, address.address1, address.city, address.state, address.country, address.zip,
        nil, nil, nil, nil, '""', 0.0
      ]
      assert_equal data.join(','), lines[3]
    end
  end

  test '#to_csv when buyer_account is nil' do
    Timecop.freeze(Time.utc(2009, 6, 25)) do
      @invoice_one.issue_and_pay_if_free!
      @invoice_one.pay!
      @buyer.destroy!
      exporter = Csv::InvoicesExporter.new(@provider, period: 'this_month', data: 'invoices')
      csv = exporter.to_csv
      lines = csv.lines.map(&:strip)
      data1 = [
        @invoice_one.id, @invoice_one.friendly_id, @invoice_one.state, @invoice_one.paid_at, @invoice_one.due_on, @invoice_one.issued_on, @invoice_one.currency, @invoice_one.cost, @invoice_one.period.begin, @invoice_one.period.end,
        nil, nil, nil, nil, nil, nil, nil,
        @line_item_one.id, @line_item_one.name, @line_item_one.description, @line_item_one.quantity, @line_item_one.type, @line_item_one.cost
      ]
      assert_equal data1.join(','), lines[3]
    end
  end
end
