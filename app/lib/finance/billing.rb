# frozen_string_literal: true

module Finance
  class Billing
    def initialize(invoice)
      @invoice = invoice
    end

    def create_line_item(params)
      bill do
        @invoice.line_items.create(params, {without_protection: true})
      end
    rescue Invoice::InvalidInvoiceStateException
      li = LineItem.new(params, {without_protection: true})
      li.errors.add(:base, :invalid_invoice_state)
      li
    end

    def create_line_item!(params)
      bill do
        @invoice.line_items.create!(params, {without_protection: true})
      end
    end

    def destroy_line_item(line_item)
      @invoice.check_editable_line_items
      LineItem.where(invoice: @invoice.id).destroy(line_item.id)
    rescue Invoice::InvalidInvoiceStateException
      line_item.errors.add(:base, :invalid_invoice_state)
      false
    end

    private

    def bill
      raise NotImplementedError, '\'bill\' must be implemented in subclasses of Billing'
    end

    attr_reader :invoice
  end
end
