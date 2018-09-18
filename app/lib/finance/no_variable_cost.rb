module Finance

  # Declarative way of saying 'this model does not have a variable
  # fee' yet it allows the model to quack like any other billable object.
  #
  module NoVariableCost

    def bill_for_variable(period, invoice, plan = nil)
    end

    def bill_variable_fee_for(period, invoice, plan = nil)
    end

    def variable_cost_paid_until
      Time.now
    end
  end
end
