# frozen_string_literal: true

Given "{buyer} is subscribed to {service_plan}" do |buyer, plan|
  plan.create_contract_with(buyer)
end
