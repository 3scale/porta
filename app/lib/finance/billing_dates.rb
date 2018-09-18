# frozen_string_literal: true

module Finance::BillingDates
  class InvalidBillingDateError < StandardError; end

  module ControllerMethods
    extend ActiveSupport::Concern

    included do
      rescue_from InvalidBillingDateError do
        render_error 'Invalid date', status: :bad_request
      end
    end

    def billing_date
      date = Date.strptime(billing_params.require(:date), '%Y-%m-%d')
      Time.utc(date.year, date.month, date.day)
    rescue ArgumentError
      raise InvalidBillingDateError
    end
  end
end
