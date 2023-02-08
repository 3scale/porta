# frozen_string_literal: true

Given "the following buyers with service subscriptions signed up to {provider}:" do |provider, table|
  table = transform_buyer_subscriptions_table(table, provider)
  table.hashes.each do |row|
    account = row[:name]
    row[:plans].each do |plan|
      contract = account.buy! plan
      contract.update_attribute(:state, row[:state]) if row[:state] # rubocop:disable Rails/SkipsModelValidations
    end
  end
end

Given "{buyer} subscribed {service}" do |buyer, service|
  plans = service.service_plans
  plan = plans.default_or_first || plans.first
  buyer.buy! plan
end

Given "{buyer} subscribed {service} with plan {string}" do |buyer, service, plan_name|
  plans = service.service_plans
  plan = plans.find_by!(name: plan_name)
  buyer.buy! plan
end

Given "a buyer {string} signed up to {service}" do |name, service|
  provider = service.account
  step %(a buyer "#{name}" signed up to provider "#{provider.name}")
  step %(buyer "#{name}" subscribed service "#{service.name}")
end
