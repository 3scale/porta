class MonthlyRevenueQuery
  class MonthlyRevenueRow < OpenStruct; end

  DASHBOARD_EARNINGS_GROUP_STATES = {
    in_process: [:open, :finalized, :pending],
    overdue: [:unpaid, :failed],
    paid: [:paid]
  }.freeze

  attr_reader :account, :options

  delegate :arel_table, :connection, to: Invoice

  # @param [Account] account is a provider Account or master
  def initialize(account, options = { include_vat: true })
    @account = account
    @options = options
  end

  # Returns an array of Hash of costs by months.
  # Each Hash has following String keys:
  #
  #   * total_cost Sum of the costs for a period excluding cancelled invoices
  #   * overdue_cost Sum of the costs of unpaid and failed invoices
  #   * in_process_cost Sum of the costs of open, pending and finalized invoices
  #   * paid_cost Sum of the costs of paid invoices
  #
  #
  # @return [Array<Hash>]

  def with_states
    arel = uncancelled_buyer_invoices
           .select([arel_table[:period], *sums_with_states])
           .group(:period)
           .joins { line_items.outer } # This is a left outer joins so if no line items the columns will be set to NULL
           .reorder(period: :desc)
    connection.select_all(arel).map { |row| MonthlyRevenueRow.new(row) }
  end

  protected

  # Delegates sanitize_sql to Invoice
  def sanitize_sql(*args)
    Invoice.send(:sanitize_sql, *args)
  end

  private

  def uncancelled_buyer_invoices
    account.buyer_invoices.not_cancelled
  end

  def sums_with_states
    sum_query_by_state = "SUM(CASE WHEN invoices.state IN (?) THEN #{cost_formula} ELSE 0 END)".freeze
    sums = DASHBOARD_EARNINGS_GROUP_STATES.map do |group, states_cases|
      sum_sql_with_state = sanitize_sql([sum_query_by_state, states_cases])
      Arel.sql(sum_sql_with_state).as("#{group}_cost")
    end
    sums << Arel.sql("SUM(#{cost_formula})").as('total_cost')
    sums
  end

  def cost_formula
    @cost_formula ||= options[:include_vat] ? 'COALESCE(cost, 0) * (1 + COALESCE(vat_rate,0) / 100)'.freeze : 'COALESCE(cost, 0)'.freeze
  end
end
