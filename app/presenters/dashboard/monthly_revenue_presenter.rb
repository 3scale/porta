class Dashboard::MonthlyRevenuePresenter < SimpleDelegator
  include ::Draper::ViewHelpers

  attr_reader :account

  def initialize(monthly_revenue, account)
    @account = account
    super(monthly_revenue)
  end

  def title
    period.strftime('%B, %Y')
  end

  def invoices_path
    h.admin_finance_invoices_path(month_number: period.month, year: period.year)
  end

  def total_revenue
    h.price_tag to_money(total_cost)
  end

  def in_process_revenue
    h.price_tag to_money(in_process_cost)
  end

  def overdue_revenue
    h.price_tag to_money(overdue_cost)
  end

  def paid_revenue
    h.price_tag to_money(paid_cost)
  end

  def to_money(cost)
    ThreeScale::Money.new(cost, account.currency)
  end

  def link_to_invoices
    h.link_to title, invoices_path, title: "See all invoices for #{title}"
  end
end
