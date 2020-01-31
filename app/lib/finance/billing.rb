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
      line_item_with_error(params, :invalid_invoice_state)
    rescue ActiveRecord::SubclassNotFound
      line_item_with_error(params.except(:type), :invalid_line_item_type)
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

    def line_item_with_error(params, error_type)
      LineItem.new(params, {without_protection: true}).tap do |line_item|
        line_item.errors.add(:base, error_type.to_sym)
      end
    end

    attr_reader :invoice
  end
end
