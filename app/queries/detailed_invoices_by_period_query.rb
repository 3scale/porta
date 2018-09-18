class DetailedInvoicesByPeriodQuery
  def initialize(account, range)
    @account = account
    @range = range
  end

  def invoices
    @invoices ||= @account.buyer_invoices
                          .where(@range ? { period: @range } : {})
                          .includes(:line_items, { buyer_account: [:country] }, :provider_account)
                          .reorder(period: :asc, created_at: :asc)
  end

  # @yield [invoice, line_item]
  # @yieldparam invoice [Invoice]
  # @yieldparam line_item [LineItem]
  def each
    return enum_for unless block_given?
    # find_each would be good but unfortunately we will lose ordering
    FindEachMocker.new(invoices).find_each do |invoice|
      if invoice.line_items.none?
        yield invoice, LineItem.new
      else
        invoice.line_items.find_each do |line_item|
          yield invoice, line_item
        end
      end
    end
  end
end
