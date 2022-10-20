# frozen_string_literal: true

class Provider::Admin::NewAccountsPresenter
  include System::UrlHelpers.system_url_helpers
  include ActiveSupport::NumberHelper
  include DashboardTimeRange

  def initialize(current_account:)
    @current_account = current_account
  end

  attr_reader :current_account

  def dashboard_widget_data
    {
      chartData: {
        values: new_accounts,
        complete: completed_chart_data,
        incomplete: incompleted_chart_data,
        previous: previous_accounts
      },
      newAccountsTotal: new_accounts.values.sum { |value| value[:value] },
      hasHistory: history?,
      links: new_accounts_links,
      percentualChange: percentual_change
    }
  end

  private

  def new_accounts_links
    last_day_on_current_range = current_range.last

    {
      previousRangeAdminBuyersAccount: {
        url: admin_buyers_accounts_path(search: { created_within: [previous_range.first, previous_range.last] }),
        value: history? ? number_to_percentage(number_to_human(percentual_change), precision: 0) : "0"
      },
      currentRangeAdminBuyersAccount: {
        url: admin_buyers_accounts_path(search: { created_within: [current_range.first, last_day_on_current_range] })
      },
      lastDayInRangeAdminBuyersAccount: {
        url: admin_buyers_accounts_path(
          search: { created_within: [last_day_on_current_range, last_day_on_current_range] }
        ),
        value: number_to_human(current_range_sum_value)
      }
    }
  end

  def completed_chart_data
    current_data_keys = new_accounts.keys
    new_accounts.slice(*current_data_keys)
  end

  def incompleted_chart_data
    current_data_keys = new_accounts.keys
    new_accounts.slice(current_data_keys.pop)
  end

  def percentual_change
    ((current_sum - previous_sum) / previous_sum) * 100
  end

  def current_sum
    completed_chart_data.values.sum { |chart_data| chart_data[:value] }.to_f
  end

  def previous_sum
    previous_accounts.values.sum { |chart_data| chart_data[:value] }.to_f
  end

  def current_range_sum_value
    incompleted_chart_data.values.sum { |chart_data| chart_data[:value] }
  end

  def history?
    previous_accounts.values.sum { |value| value[:value] }.positive?
  end

  def new_accounts
    @new_accounts ||= accounts_within_timeframe(current_range)
  end

  def previous_accounts
    @previous_accounts ||= accounts_within_timeframe(previous_range)
  end

  def accounts_within_timeframe(range)
    new_accounts_query.within_timeframe(range: range).map do |(date, value)|
      value_data = { value: value, formatted_value: number_to_human(value) }

      [date, value_data]
    end.to_h
  end

  def new_accounts_query
    NewAccountsQuery.new(current_account)
  end
end
