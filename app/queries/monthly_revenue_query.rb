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
  def initialize(account:, params: {}, options: { include_vat: true })
    @account = account
    @options = options
    pagination_params = { page: params[:page], per_page: params[:per_page] || 20 }
    selected_year = params.dig(:search, :year)

    selection = [arel_table[:period], *sums_with_states]
    grouped = uncancelled_buyer_invoices.selecting { selection }
                                        .group(:period)
    filtered = selected_year.nil? ? grouped : grouped.by_year(selected_year)
    @raw_arel = filtered.paginate(pagination_params)
  end

  module CastValues
    def cast_values(klass = Hash)
      hash_rows.map do |row|
        row.each_with_object(klass.new) do |(key, value), memo|
          column_type = column_types[key]
          memo[key] = column_type.present? ? column_type.cast(value) : value
        end
      end
    end
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
    arel = @raw_arel.joins { line_items.outer } # This is a left outer joins so if no line items the columns will be set to NULL
                    .reorder(period: :desc)
    result = connection.select_all(arel).extend(CastValues)
    result.cast_values(MonthlyRevenueRow)
  end

  def total_entries
    @raw_arel.total_entries
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
    sum_query_by_state = "CASE WHEN invoices.state IN (?) THEN #{cost_formula} ELSE 0 END".freeze
    sums = DASHBOARD_EARNINGS_GROUP_STATES.map do |group, states_cases|
      sum_sql_with_state = sanitize_sql([sum_query_by_state, states_cases])
      Arel.sql(sum_sql_with_state).sum.as("#{group}_cost")
    end
    sums << Arel.sql(cost_formula).sum.as('total_cost')
    sums
  end

  def cost_formula
    @cost_formula ||= options[:include_vat] ? 'COALESCE(cost, 0) * (1 + COALESCE(vat_rate,0) / 100)'.freeze : 'COALESCE(cost, 0)'.freeze
  end
end
