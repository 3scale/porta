# TODO: differentiate this for buyer and provider
module Finance::InvoicesHelper

  def mark_if_deleted(object, name)
    if object.nil?
      content_tag(:span, '(deleted)', :class => 'deleted')
    else
      object.send(name)
    end
  end

  alias guillaume_if_deleted mark_if_deleted

  def account_header_optional_field(name, account)
    value = account.send(name)
    return unless value.present?

    content_tag :tr do
      row =  content_tag :th, name.to_s.humanize
      row += content_tag :td, h(value), :colspan => 2
      row
    end
  end


  def invoice_field(name, value, action = nil, options = {})
    title = case name
            when Symbol
        Invoice.human_attribute_name(name)
            else
        name
    end

    content_tag :tr do
      row = content_tag(:th, title)
      row += content_tag(:td, value, :id => "field-#{name.to_s.downcase}")
      row += content_tag(:td, action)
      row
    end
  end

  def current_invoice_link(buyer)
    link_to 'Current invoice',
            admin_finance_account_invoice_path(buyer, buyer.current_invoice.to_param),
            :title => "Current invoice for #{h(buyer.org_name)}"
  end

  def invoice_action_button(name, action, modifier)
    url = send("#{action}_admin_finance_invoice_path", @invoice.id, :format => :js)
    pf_class = "pf-c-button pf-m-#{modifier}"
    fancy_button_to(name, url, :method => :put, :remote => true, :class => pf_class)
  end


  def invoice_pdf_link(invoice, label = 'Download PDF')
    if invoice.pdf.file?
      link_to(label, invoice.pdf.expiring_url)
    else
      content_tag(:em,'not yet generated')
    end
  end

  def pf_invoice_pdf_link(invoice, label = 'Download PDF')
    if invoice.pdf.file?
      pf_link_as_button(label, invoice.pdf.expiring_url, modifier: 'secondary')
    else
      content_tag(:em,'not yet generated')
    end
  end

  def line_item_price_tag(cost)
    price_tag(cost, precision: LineItem::DECIMALS)
  end

  def rounded_price_tag(cost)
    price_tag(cost, precision: Invoice::DECIMALS)
  end

  private

  def invoice_date_format(date)
    date ? date.strftime("%e %B, %Y") : '-'
  end
end
