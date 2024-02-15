# frozen_string_literal: true

Then /^(?:the)? (?:buyer|provider|account) "([^"]*)" should have (?:a|an)(?: (pending|live|suspended))? (account|service|application) contract(?: with the plan "([^"]*)")?$/ do |account, state, type , plan|
  account = Account.find_by!(org_name: account)
  plan = Plan.find_by!(name: plan) if plan

  conditions = {}
  conditions[:state] = state if state.present?
  conditions[:plans] = {:type => "#{type.camelize}Contract"}
  conditions[:plan_id] = plan.id if plan
  conditions[:user_account_id] = account.id

  contracts = account.contracts.where(conditions).includes(:plan)
  assert_not_nil contracts
end
