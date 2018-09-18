# frozen_string_literal: true

class Csv::InvoicesExporter < ::Csv::Exporter
  INVOICE_HEADERS = [
    'Invoice Id', 'Invoice Friendly Id', 'Invoice State', 'Paid At', 'Due On',
    'Issued On', 'Currency', 'Invoice Cost', 'From', 'To'
  ].freeze

  BUYER_HEADERS = [
    'Account Id', 'Organization Name', 'Address', 'City', 'State', 'Country', 'Zip Code'
  ].freeze

  LINE_ITEM_HEADERS = [
    'Invoice Line Id', 'Name', 'Description', 'Quantity', 'Type', 'Invoice Line Cost'
  ].freeze

  CSV_HEADERS = (INVOICE_HEADERS + BUYER_HEADERS + LINE_ITEM_HEADERS).freeze

  def generate
    super do |csv|
      csv << header
      csv << []
      csv << CSV_HEADERS

      query = DetailedInvoicesByPeriodQuery.new(@account, @range)
      query.each do |invoice, line_item|
        csv << values_for(invoice, line_item)
      end
    end
  end

  protected

  def values_for(invoice, line_item)
    buyer_account = invoice.buyer_account
    invoice_values(invoice) + buyer_values(buyer_account) + line_item_values(line_item)
  end

  def invoice_values(invoice)
    [
      invoice.id, invoice.friendly_id, invoice.state, invoice.paid_at, invoice.due_on,
      invoice.issued_on, invoice.currency, invoice.cost, invoice.period.begin, invoice.period.end
    ]
  end

  def buyer_values(buyer_account)
    if buyer_account
      address = buyer_account.billing_address
      [
        buyer_account.id, buyer_account.org_name,
        address.address1, address.city, address.state, address.country, address.zip
      ]
    else
      Array.new(BUYER_HEADERS.size)
    end
  end

  def line_item_values(line_item)
    [
      line_item.id, line_item.name, line_item.description,
      line_item.quantity, line_item.type, line_item.cost
    ]
  end
end
