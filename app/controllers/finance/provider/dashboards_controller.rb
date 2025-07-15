# frozen_string_literal: true

class Finance::Provider::DashboardsController < Finance::Provider::BaseController
  include Finance::InvoicesHelper

  activate_menu :audience, :finance, :earnings

  helper_method :months, :toolbar_props

  def show
    @query = MonthlyRevenueQuery.new(account: current_account, params:)
  end

  private

  def months
    @months ||= @query.with_states.map { |row| Dashboard::MonthlyRevenuePresenter.new(row, current_account) }
  end

  def toolbar_props
    {
      filters: [{
        attribute: 'year',
        collection: years_for_filter,
        placeholder: 'Filter by year'
      }],
      totalEntries: @query.total_entries
    }
  end

  def years_for_filter
    years.map do |year|
      { id: year.to_s, title: year.to_s }
    end
  end

  def years
    @years ||= years_by_provider(current_account)
  end
end
