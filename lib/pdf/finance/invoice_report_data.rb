require "open-uri"

# Wrapper for Invoice that supplies all the data needed for invoice.
class Pdf::Finance::InvoiceReportData

  LINE_ITEMS_HEADING = %w(Name Quantity Cost Charged).freeze
  DATE_FORMAT = "%e %B, %Y".freeze

  delegate :name, :cost, :to => :@invoice

  def initialize(invoice)
    @invoice = invoice
  end

  def buyer
    person_data(@invoice.to, @invoice.fiscal_code, @invoice.vat_code, po_number)
  end

  def provider
    person_data(@invoice.from, @invoice.provider.fiscal_code, @invoice.provider.vat_code, nil)
  end

  def issued_on
    format_date(@invoice.issued_on)
  end

  def due_on
    format_date(@invoice.due_on)
  end

  def period_start
    format_date(@invoice.period.begin)
  end

  def period_end
    format_date(@invoice.period.end)
  end

  def filename
    date = @invoice.created_at.strftime('%B-%Y').downcase
    "invoice-#{date}.pdf"
  end

  def email
    provider.finance_support_email
  end

  def plan
    @invoice.buyer_account.bought_plan.name
  end

  def logo
    @logo_stream ||= open(@invoice.provider_account.profile.logo.url(:invoice))
  rescue => e
    # TODO: - uncomment complete exception!
    # rescue OpenURI::HTTPError => e
    Rails.logger.error "Failed to retrieve logo from: #{e.message}"
    nil
  end

  def has_logo?
    @invoice.provider_account.profile.logo.file? && logo
  end

  def line_items
    line_items = @invoice.line_items.map do |item|
      [ CGI.escapeHTML(item.name || ""), item.quantity || '', item.cost.round(LineItem::DECIMALS), '' ]
    end

    if @invoice.vat_rate.nil?
      total = [ 'Total cost', '', @invoice.exact_cost_without_vat, @invoice.charge_cost ]
      line_items << total
    else
      vat_rate_label = @invoice.buyer_account.field_label('vat_rate')

      total_without_vat = [ "Total cost (without #{vat_rate_label})", '', @invoice.exact_cost_without_vat, @invoice.charge_cost_without_vat ]
      total_vat = [ "Total #{vat_rate_label} Amount", '', @invoice.vat_amount, @invoice.charge_cost_vat_amount ]
      total = [ "Total cost (#{vat_rate_label} #{@invoice.vat_rate}% included)",     '', '', @invoice.charge_cost ]

      line_items << total_without_vat << total_vat << total
    end
  end

  def vat_rate
    @invoice.vat_rate
  end

  def friendly_id
    @invoice.friendly_id
  end

  def invoice_footnote
    CGI.escapeHTML(@invoice.provider_account.invoice_footnote || "")
  end

  def vat_zero_text
    CGI.escapeHTML(@invoice.provider_account.vat_zero_text || "")
  end

  def po_number
    CGI.escapeHTML(@invoice.buyer_account.po_number || "")
  end

  private

  def person_data(address, fiscal_code, vat_code, po_number)
    location = []
    location << [ address.line1, address.line2 ].compact.join(' ')
    location << [ address.city, [address.state, address.zip ].compact.join(' ')].compact.join(', ')

    pd = [ [ 'Name',    CGI.escapeHTML(address.name || '') ],
           [ 'Address', CGI.escapeHTML(location.join("\n" || ''))],
           [ 'Country', CGI.escapeHTML(address.country || '') ] ]

    pd << [ 'Fiscal code', CGI.escapeHTML(fiscal_code) ] if fiscal_code.present?
    pd << [ @invoice.buyer_account.field_label('vat_code'), CGI.escapeHTML(vat_code) ] if vat_code.present?
    pd << [ 'PO num',    CGI.escapeHTML(po_number)    ] if po_number.present?

    pd
  end

  def format_date(date)
    date ? date.strftime(DATE_FORMAT) : '-'
  end
end
