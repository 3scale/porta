Then /^(?:the)? ((?:buyer|provider|account) "[^"]*") should have (?:a|an)(?: (pending|live|suspended))? (account|service|application) contract(?: with the (plan "[^"]*"))?$/ do |account, state, type , plan|
  conditions = {}
  conditions[:state] = state if state.present?
  conditions[:plans] = {:type => "#{type.camelize}Contract"}
  conditions[:plan_id] = plan.id if plan
  conditions[:user_account_id] = account.id

  contracts = account.contracts.where(conditions).includes(:plan)
  assert_not_nil contracts
end


When /^the contract of (buyer "[^"]*") with (plan "[^"]*") is approved$/ do |buyer, plan|
  contract = buyer.contracts.by_plan_id(plan.id).first
  contract.accept!
end

When /^the provider (accept|suspend|resume)s the buyer's (application|service|service) plan contract$/ do |verb, plan_type|
  plan = instance_variable_get("@paid_#{plan_type}_plan")
  contract = @buyer.contracts.by_plan_id(plan.id).first
  contract.public_send("#{verb}!")
end
