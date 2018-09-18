module Finance

  # Including this module makes a model billable for fixed fee.
  # Attribute +plan+ with method #cost_for_period is required to exist
  # on the class, strictly speaking.
  #
  module FixedFee

    protected

    def bill_fixed_fee_for(period, invoice)
      fixed_cost = plan.cost_for_period(period)
      if fixed_cost.nonzero?
        Finance::BackgroundBilling.new(invoice).create_line_item!(
          {
            contract: self,
            plan_id: plan_id,
            name: "Fixed fee ('#{plan.name}')",
            description: period.to_time_range.to_s,
            quantity: 1,
            cost: fixed_cost,
            type: LineItem::PlanCost
          }
        )
      end
    end
  end
end
