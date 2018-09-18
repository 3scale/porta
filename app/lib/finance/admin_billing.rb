# frozen_string_literal: true

module Finance
  class AdminBilling < Billing
    private

    def bill
      invoice.check_editable_line_items
      yield
    end
  end
end
