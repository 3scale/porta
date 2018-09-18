module Finance
  module SetupFee

    protected

    def bill_setup_fee_for(period, invoice)
      if setup_fee && setup_fee.nonzero?
        Finance::BackgroundBilling.new(invoice).create_line_item!(
          {
            contract: self,
            plan_id: plan_id,
            name: "Setup fee ('#{plan.name}')",
            cost: setup_fee,
            type: LineItem::PlanCost
          }
        )
        self.setup_fee = nil
      end
    end
  end
end
