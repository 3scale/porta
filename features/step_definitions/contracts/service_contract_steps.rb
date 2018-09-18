Given /^(buyer "[^"]*") is subscribed to (service plan "[^"]*")$/ do |buyer, plan|
  plan.create_contract_with(buyer)
end

