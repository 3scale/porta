# frozen_string_literal: true

class Provider::Admin::Dashboards::NewAccountsPresenter
  include ::Draper::ViewHelpers
  include ActionView::Helpers::NumberHelper

  ID = 'new-accounts-widget'
  NAME = :new_accounts

  attr_reader :chart, :current_sum, :current

  def initialize(data) # rubocop:disable Metrics/AbcSize
    current_data = data.delete(:new_accounts)
    previous_data = data.delete(:previous_accounts)

    current_data_keys = current_data.keys
    incomplete_slice = current_data.slice(current_data_keys.pop)
    current_slice = current_data.slice(*current_data_keys)
    current_sum = get_sum_from_values(current_slice.values)
    previous_sum = get_sum_from_values(previous_data.values)

    @current_sum = current_sum
    @current = incomplete_slice.values.first&.fetch(:formatted_value, '0')
    @history = previous_sum.positive?
    @percentage_change = ((current_sum.to_f - previous_sum.to_f) / previous_sum.to_f) * 100
    @chart = {
      values: current_data,
      complete: current_slice,
      incomplete: incomplete_slice,
      previous: previous_data
    }
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

  private

  def get_sum_from_values(values)
    values.sum { |value| value[:value] }
  end
end
