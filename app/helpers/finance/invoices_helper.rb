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

  def current_invoice_link(buyer)
    link_to 'Current invoice',
            admin_finance_account_invoice_path(buyer, buyer.current_invoice.to_param),
            :title => "Current invoice for #{h(buyer.org_name)}"
  end

  def invoice_action_button(name, action, modifier)
    fancy_button_to(name, send("#{action}_admin_finance_invoice_path", @invoice.id, format: :js),
                          method: :put,
                          remote: true,
                          class: "pf-c-button pf-m-#{modifier}",
                          confirm: t('.confirm'))
  end


  def invoice_pdf_link(invoice, options = {})
    label = options.delete(:label) || 'Download PDF'
    if invoice.pdf.file?
      link_to(label, invoice.pdf.expiring_url, options)
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
