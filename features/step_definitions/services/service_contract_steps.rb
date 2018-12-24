Given /^the following buyers with service subscriptions signed up to (provider "[^"]*"):$/ do |provider, table|
  # table is a Cucumber::Ast::Table
  table.map_column!(:plans) { |plans| plans.from_sentence.map{ |plan| Plan.find_by_name!(plan) } }
  table.map_column!(:name) { |name| FactoryBot.create :buyer_account, :provider_account => provider, :org_name => name }
  table.map_headers! { |header| header.to_sym }
  table.hashes.each do |row|
    account = row[:name]
    row[:plans].each do |plan|
      contract = account.buy! plan
      contract.update_attribute(:state,  row[:state]) if row[:state]
    end
  end
end

Given /^(buyer "[^"]*") subscribed (service "[^"]*")(?: with plan "([^"]*)")?$/ do |buyer, service, plan_name|
  plans = service.service_plans

  plan = if plan_name
    plans.find_by_name! plan_name
         else
    plans.default_or_first or plans.first
  end

  buyer.buy! plan
end

Given /^a buyer "([^"]*)" signed up to (service "[^"]*")$/ do |name, service|
  provider = service.account
  step %{a buyer "#{name}" signed up to provider "#{provider.name}"}
  step %{buyer "#{name}" subscribed service "#{service.name}"}
end

