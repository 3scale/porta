class Finance::Builder::XmlMarkup
  attr_reader :builder
  delegate :to_xml, :to => :builder

  VERSION = '1.0'

  def initialize(options = {})
    @builder = options[:builder] || ThreeScale::XML::Builder.new
  end

  def self.supports_version?(version)
    version == VERSION
  end

  # TODO: move to index.xml.builder
  def self.invoices!(items)
    builder = ThreeScale::XML::Builder.new
    builder.invoices(:version => VERSION) do |xml|
      xml.pagination(:total_pages => items.total_pages,
                    :current_page => items.current_page,
                    :per_page => items.per_page,
                    :total_entries => items.total_entries)
      items.each { |i| i.to_xml(:builder => xml ) }
    end

    builder.to_xml
  end

  def invoice!(invoice)
    builder.invoice(:version => VERSION) do |xml|
      xml.id_ invoice.id
      xml.friendly_id invoice.friendly_id
      xml.creation_type invoice.creation_type

      xml.state invoice.state
      date!(xml, :paid_at, invoice.paid_at)
      date!(xml, :due_on, invoice.due_on)
      date!(xml, :issued_on, invoice.issued_on)

      xml.currency         invoice.currency
      xml.cost             invoice.cost
      if invoice.vat_rate.try!(:>, 0)
        xml.vat_rate       invoice.vat_rate
        xml.vat_amount     invoice.vat_amount
      end
      xml.cost_without_vat invoice.exact_cost_without_vat

      xml.period do |xml|
        date!(xml, :from, invoice.period.begin)
        date!(xml, :to,   invoice.period.end)
      end

      account!(xml, :provider, invoice.provider_account, invoice.from.presence) # presence is overloaded
      if invoice.buyer_account
        account!(xml, :buyer, invoice.buyer_account, invoice.to.presence) # presence is overloaded
      else
        xml.buyer do |xml|
          xml.id_ invoice.buyer_account_id
          xml.status "deleted"
        end
      end

      invoice.line_items.to_xml(:builder => builder,
                                :root => 'line-items')

      xml.payment_transactions_count invoice.payment_transactions.size
    end

    builder
  end

  def line_item!(item)
    builder.__send__(:method_missing, 'line-item') do |xml|
      xml.id_ item.id
      xml.name item.name
      xml.description item.description
      xml.quantity item.quantity
      xml.type item.type
      xml.metric_id item.metric_id if item.respond_to?(:metric)
      xml.plan_id item.plan_id
      xml.contract_id item.contract_id
      xml.contract_type item.contract_type
      xml.cost item.cost
    end
  end

  def date!(xml, name, value)
    xml.__send__(:method_missing, name, value.to_s)
  end

  def account!(xml, name, account, address = nil)
    address ||= account.billing_address

    xml.__send__(:method_missing, name) do |xml|
      xml.id_ account.id
      xml.org_name account.org_name
      xml.address [ address.line1, address.line2 ].compact.join("\n")
      xml.city address.city
      xml.state address.state
      xml.country address.country
      xml.phone address.phone
      xml.zip address.zip
    end
  end
end
