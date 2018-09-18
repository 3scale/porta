require 'test_helper'

class Dashboard::MonthlyRevenuePresenterTest < Draper::TestCase
  def setup
    @account = Account.new
    @account.stubs(currency: 'USD')
    monthly_revenue = MonthlyRevenueQuery::MonthlyRevenueRow.new(period: '2016-06-15'.to_date, in_process_cost: 100.90, overdue_cost: 8.67, paid_cost: 503.27, total_cost: 612.82)
    @presenter = Dashboard::MonthlyRevenuePresenter.new(monthly_revenue, @account)
  end

  test '#title' do
    assert_equal 'June, 2016', @presenter.title
  end

  test '#invoices_path' do
    assert_equal '/finance/invoices?month_number=6&year=2016', @presenter.invoices_path
  end

  test '#total_revenue' do
    assert_equal 'USD&nbsp;612.82', @presenter.total_revenue
  end

  test '#in_process_revenue' do
    assert_equal 'USD&nbsp;100.90', @presenter.in_process_revenue
  end

  test '#overdue_revenue' do
    assert_equal 'USD&nbsp;8.67', @presenter.overdue_revenue
  end

  test '#paid_revenue' do
    assert_equal 'USD&nbsp;503.27', @presenter.paid_revenue
  end
end
