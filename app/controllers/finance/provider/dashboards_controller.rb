class Finance::Provider::DashboardsController < Finance::Provider::BaseController
  activate_menu :audience, :finance, :earnings

  def show
    rows = MonthlyRevenueQuery.new(current_account).with_states
    @months = rows.map { |row| Dashboard::MonthlyRevenuePresenter.new(row, current_account) }
  end
end
