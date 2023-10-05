# frozen_string_literal: true

Given "the following buyers with service subscriptions signed up to {provider}:" do |provider, table|
  # table is a Cucumber::MultilineArgument::DataTable
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
  step %{a buyer "#{name}" signed up to provider "#{provider.name}"}
  step %{buyer "#{name}" subscribed service "#{service.name}"}
end

When "the subscription will return an error when suspended" do
  ServiceContract.any_instance.stubs(:suspend).returns(false).at_least_once
end

When "the subscription will return an error when changing its plan" do
  ServiceContract.any_instance.stubs(:change_plan).returns(false).at_least_once
end
