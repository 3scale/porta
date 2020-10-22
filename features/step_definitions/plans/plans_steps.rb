# frozen_string_literal: true

Given "the {provider} has following {plan_type} plan(s)" do |provider, plan_type, table|
  plan_type = plan_type.parameterize.underscore

  table.hashes.each do |row|
    FactoryBot.create plan_type, row.reverse_merge!(issuer: provider.first_service!)
  end
end

Given "a published service plan {string} of {service_of_provider}" do |plan_name, service|
  create_plan :service, name: plan_name, issuer: service, published: true
end

Given "a default published service plan {string} of {service_of_provider}" do |plan_name, service|
  create_plan :service, name: plan_name, issuer: service, published: true, default: true
end

Given "a published application plan {string} of {service_of_provider}" do |plan_name, service|
  create_plan :application, name: plan_name, issuer: service, published: true
end

Given "a default published application plan {string} of {service_of_provider}" do |plan_name, service|
  create_plan :application, name: plan_name, issuer: service, published: true, default: true
end

Given "the provider has a {default} free application plan" do |default|
  step %(the provider has a #{default ? 'default' : ''} free application plan "Copper").squish
end

Given "the provider has a {default} free application plan {string}" do |default, plan_name|
  @free_application_plan ||= create_plan :application, name: plan_name, issuer: @service, published: true, default: default
end

# TODO: convert this to cucumber expression
Given(/^the provider has a(nother|\ second|\ third)? (default )?paid (application|service|account) plan(?: "([^\"]*)")?(?: of (\d+) per month)?$/) do |other, default, plan_type, plan_name, cost|
  plan_type_name = (other ? "#{other.strip}_" : '') + plan_type
  return instance_variable_get("@paid_#{plan_type_name}_plan") if instance_variable_defined?("@paid_#{plan_type_name}_plan")

  default_plan_names = {
    application: 'Gold',
    service: 'Star',
    account: 'Premium'
  }
  default_plan_costs = {
    application: 100,
    service: 10,
    account: 1
  }
  plan_name = (plan_name || default_plan_names[plan_type])
  plan = create_plan plan_type.to_sym, name: plan_name, issuer: @service, cost: (cost || default_plan_costs[plan_type]), published: true, default: default.present?
  instance_variable_set("@paid_#{plan_type_name}_plan", plan)
end

# TODO: convert this to cucumber expression
PLANS = /account|service|application/
Given /^(?:a|an)( default)?( published)? (#{PLANS}) plan "([^\"]*)" (?:of|for) ((?:provider|service) "[^\"]*")(?: for (\d+) monthly)?(?: exists)?$/ do |default, published, type, plan_name, issuer, cost|
  type ||= :application
  create_plan type, :name => plan_name, :issuer => issuer, :cost => cost, :default => default, :published => published
end

# Given "a published {plan_type} plan {string} of/for {service}( exists)" do |plan_type, plan_name, service|
#   plan_type ||= :application
#   create_plan(plan_type, name: plan_name, issuer: service, cost: 0, published: true)
# end

# Given "a/an {plan_type} plan {string} of/for {service}( exists)" do |plan_type, plan_name, service|
#   plan_type ||= :application
#   create_plan(plan_type, name: plan_name, issuer: service, cost: 0)
# end

# Given "a published {plan_type} plan {string} of {provider}" do |plan_type, plan_name, provider|
#   plan_type ||= :application
#   create_plan(plan_type, name: plan_name, issuer: provider, cost: 0, published: true)
# end

# Given "a/an {plan_type} plan {string} of {provider}" do |plan_type, plan_name, provider|
#   plan_type ||= :application
#   create_plan(plan_type, name: plan_name, issuer: provider, cost: 0)
# end

# Given "a default {plan_type} plan {string} of {provider}" do |plan_type, plan_name, provider|
#   plan_type ||= :application
#   create_plan(plan_type, name: plan_name, issuer: provider, cost: 0, default: true)
# end

Given "{buyer} signed up for plans {}" do |buyer, list|
  list.each do |name|
    name = name.strip.delete('"')
    sign_up(buyer, name)
  end
end

Given "the buyer signed up for provider's paid {plan_type} plan" do |plan_type|
  plan = instance_variable_get("@paid_#{plan_type}_plan")
  sign_up(@buyer, plan.name)
end

Given "the buyer signed up for plan {string}" do |plan_name|
  sign_up(@buyer, plan_name)
end

Given "the buyer changed to plan {string}" do |plan_name|
  plan = Plan.find_by(name: plan_name)
  @buyer.bought_cinstance.change_plan!(plan)
end

Given "the buyer's {plan_type} plan contract is {}" do |plan_type, state|
  plan = instance_variable_get("@paid_#{plan_type}_plan")
  contract = @buyer.contracts.where(plan_id: plan.id).first!
  contract.update!(state: state)
end

Given "{plan} is {published}" do |plan, published|
  if published
    plan.publish! unless plan.published?
  else
    plan.hide! unless plan.hidden?
  end
end

Given "account/service/application {plan} requires approval( of contracts)" do |plan|
  plan.update!(approval_required: true)
end

Given "the application {string} of the partner {string} has a trial period of {int} day(s)" do |application_name, buyer_name, days|
  cinstance = @provider.buyers.where(org_name: buyer_name)
                              .first
                              .application_contracts
                              .where(name: application_name)
                              .first
  cinstance.trial_period_expires_at = Time.zone.now + days.days
  cinstance.save!
end

Given "I want to change the plan of my application to paid" do
  steps %(
    Given the buyer logs in to the provider
    And I go to my application page
    And I follow "Edit #{@application.name}"
    And I follow "Review/Change"
    And I follow "#{@paid_application_plan.name}"
  )
end

Given "master has (an )application plan {string}" do |plan_name|
  create_plan :application, name: plan_name, issuer: Account.master
end
