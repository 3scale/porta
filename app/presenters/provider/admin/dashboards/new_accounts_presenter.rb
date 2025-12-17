# frozen_string_literal: true

class Provider::Admin::Dashboards::NewAccountsPresenter
  include ::Draper::ViewHelpers
  include ActionView::Helpers::NumberHelper

  ID = 'new-accounts-widget'
  NAME = :new_accounts

  attr_reader :rest_days_signups, :todays_sinups, :chart_data

  def initialize(data)
    new_accounts = data.delete(:new_accounts)
    old_accounts = data.delete(:previous_accounts)

    *rest_days, today = new_accounts.to_a
    @rest_days_signups = rest_days.sum(&:last)
    @todays_sinups = today.last

    old_signups = old_accounts.values.sum.to_f
    @history = old_signups.positive?
    @percentage_change = history? ? ((rest_days_signups.to_f - old_signups) / old_signups) * 100 : 0
    @chart_data = new_accounts.map do |date, value|
      [date, number_to_human(value)]
    end
  end

  def id
    ID
  end

  def render
    h.render "provider/admin/dashboards/widgets/#{NAME}", widget: self
  end

  def history?
    @history
  end

  def title_with_history
    format('%+d', @percentage_change)
  end

  def no_signups?
    rest_days_signups.zero? && todays_signups.zero? && !history?
  end
end
