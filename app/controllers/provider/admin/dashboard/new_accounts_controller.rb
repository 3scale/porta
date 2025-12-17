# frozen_string_literal: true

class Provider::Admin::Dashboard::NewAccountsController < Provider::Admin::Dashboard::WidgetBaseController
  protected

  include ActiveSupport::NumberHelper

  def presenter
    Provider::Admin::Dashboards::NewAccountsPresenter
  end

  def widget_data
    {
      new_accounts: new_accounts,
      previous_accounts: previous_accounts
    }
  end

  private

  def new_accounts
    @new_accounts ||= accounts_within_timeframe(current_range)
  end

  def previous_accounts
    @previous_accounts ||= accounts_within_timeframe(previous_range)
  end

  def accounts_within_timeframe(range)
    NewAccountsQuery.new(current_account)
                    .within_timeframe(range:)
  end
end
