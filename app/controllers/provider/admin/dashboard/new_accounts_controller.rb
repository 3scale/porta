class Provider::Admin::Dashboard::NewAccountsController < Provider::Admin::Dashboard::WidgetController
  include ActiveSupport::NumberHelper

  protected

  def widget_data
    timeline_data(new_accounts, previous_accounts)
  end

  def chart_data
    new_accounts
  end

  def new_accounts
    @_new_accounts ||= accounts_within_timeframe(current_range)
  end

  def previous_accounts
    @_previous_accounts ||= accounts_within_timeframe(previous_range)
  end

  private

  def accounts_within_timeframe(range)
    new_accounts_query.within_timeframe(range: range).map do |(date, value)|

      value_data = {
        value:           value,
        formatted_value: number_to_human(value)
      }

      [date, value_data]
    end.to_h
  end

  def new_accounts_query
    NewAccountsQuery.new(current_account)
  end
end
