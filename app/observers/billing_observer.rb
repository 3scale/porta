# frozen_string_literal: true
class BillingObserver < ActiveRecord::Observer

  class RangeForVariableCost < Range
    def distance_in_seconds
      (self.end.in_time_zone('UTC') - self.begin.in_time_zone('UTC')).to_i
    end

    def empty?
      distance_in_seconds.zero?
    end
  end

  observe :contract

  # It is called 'manually' from Contract#notify_plan_changed

  def bill_variable_for_plan_changed(contract, plan)
    if contract.provider_account.provider_can_use?(:instant_bill_plan_change)
      invoice_period = Month.new(Time.now)
      current_invoice = Finance::InvoiceProxy.new(contract.account, invoice_period)
      current_invoice.mark_as_used

      period_from = [contract.variable_cost_paid_until, invoice_period.begin].max
      last_midnight = Date.today.beginning_of_day
      period = RangeForVariableCost.new(period_from, last_midnight)

      contract.bill_for_variable(period, current_invoice, plan) unless period.try(:empty?)
    end
  end

  def plan_changed(contract)
    now = Time.now.utc

    strategy = contract.buyer_account.provider_account.try(:billing_strategy)

    entitlements_options = { previous_plan: contract.old_plan }

    if !contract.trial?(now) && strategy
      period = TimeRange.new(now, now.end_of_month)
      entitlements_options[:invoice] = strategy.bill_plan_change(contract, period).try(:invoice)
      contract.update_attribute :paid_until, now.end_of_month # TODO: move this line inside the billing strategy
    end

    SupportEntitlementsService.notify_entitlements(contract.account, entitlements_options)
  end
end
