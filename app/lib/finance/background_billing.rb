# frozen_string_literal: true

module Finance
  class BackgroundBilling < Billing
    private

    def bill
      return unless invoice.should_bill?
      invoice.mark_as_used
      invoice.check_editable_line_items
      yield
    end
  end
end
