# frozen_string_literal: true

# TODO: distinguish ServicePlan in param type
Given "{buyer} is subscribed to service {plan}" do |buyer, plan|
  plan.create_contract_with(buyer)
end
