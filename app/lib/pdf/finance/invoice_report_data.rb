# frozen_string_literal: true

require "open-uri"

# Wrapper for Invoice that supplies all the data needed for invoice.
class Pdf::Finance::InvoiceReportData

  LINE_ITEMS_HEADING = %w[Name Quantity Cost Charged].freeze
  DATE_FORMAT = "%e %B, %Y"
  LOGO_ATTACHMENT_STYLE = :invoice

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

  def with_logo
    raise ArgumentError, 'Calling #with_logo requires a block' unless block_given?

    io = logo_io
    yield io
  ensure
    io&.close
  end

  def line_items
    line_items = @invoice.line_items.map do |item|
      [item.name || "", item.quantity || '', item.cost.round(LineItem::DECIMALS), '']
    end

    line_items.push(*total_invoice_label)
  end

  def vat_rate
    @invoice.vat_rate
  end

  def friendly_id
    @invoice.friendly_id
  end

  def invoice_footnote
    @invoice.provider_account.invoice_footnote || ""
  end

  def vat_zero_text
    @invoice.provider_account.vat_zero_text || ""
  end

  def po_number
    @invoice.buyer_account.po_number || ""
  end

  private

  def person_data(address, fiscal_code, vat_code, po_number)
    pd = [['Name',    address.name || ''],
          ['Address', location_text(address)],
          ['Country', address.country || '']]
    pd << ['Fiscal code', fiscal_code] if fiscal_code.present?
    pd << [@invoice.buyer_account.field_label('vat_code'), vat_code] if vat_code.present?
    pd << ['PO num', po_number] if po_number.present?
    pd
  end

  def location_text(address)
    location = []
    location << [address.line1, address.line2].compact.join(' ')
    location << [address.city, [address.state, address.zip].compact.join(' ')].compact.join(', ')
    location.join("\n") || ''
  end

  def format_date(date)
    date ? date.strftime(DATE_FORMAT) : '-'
  end

  def total_invoice_label
    if @invoice.vat_rate.nil?
      total = ['Total cost', '', @invoice.exact_cost_without_vat, @invoice.charge_cost]
      [total]
    else
      vat_rate_label = @invoice.buyer_account.field_label('vat_rate')

      total_without_vat = ["Total cost (without #{vat_rate_label})", '', @invoice.exact_cost_without_vat, @invoice.charge_cost_without_vat]
      total_vat = ["Total #{vat_rate_label} Amount", '', @invoice.vat_amount, @invoice.charge_cost_vat_amount]
      total = ["Total cost (#{vat_rate_label} #{@invoice.vat_rate}% included)",     '', '', @invoice.charge_cost]

      [total_without_vat, total_vat, total]
    end
  end

  def logo
    @logo ||= @invoice.provider_account.profile.logo
  end

  # Depending on the storage option for the attachment:
  # - retrieve either the full path of the local file, or the URL of the file in S3
  # - read the file differently
  def logo_io
    case storage = logo.options[:storage].to_sym
    when :filesystem
      # read as binary file 'b'
      File.open(logo.path(LOGO_ATTACHMENT_STYLE), 'rb')
    when :s3
      URI.parse(logo.expiring_url(CMS::S3::DEFAULT_EXPIRES_IN, LOGO_ATTACHMENT_STYLE)).open
    else
      raise "Invalid attachment type #{storage}"
    end
  rescue StandardError => exception
    Rails.logger.error "Failed to retrieve logo: #{exception.message}"
    nil
  end
end
