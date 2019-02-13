PLANS = /account|service|application/

Given /^the (provider ".+?") has following (#{PLANS} plan)s?:$/ do |provider, plan, table|
  plan = plan.parameterize.underscore # application plan => application_plan

  table.hashes.each do |row|
    FactoryBot.create plan, row.reverse_merge!(:issuer => provider.first_service!)
  end
end

Given /^a published service plan "([^\"]*)" of (service "[^\"]*" of provider "[^\"]*")$/ do |plan_name, service|
  create_plan :service, :name => plan_name, :issuer => service, :published => true
end

Given /^a default published service plan "([^\"]*)" of (service "[^\"]*" of provider "[^\"]*")$/ do |plan_name, service|
  create_plan :service, :name => plan_name, :issuer => service, :published => true, :default => true
end

Given /^a published application plan "([^\"]*)" of (service "[^\"]*" of provider "[^\"]*")$/ do |plan_name, service|
  create_plan :application, :name => plan_name, :issuer => service, :published => true
end

Given /^a default published application plan "([^\"]*)" of (service "[^\"]*" of provider "[^\"]*")$/ do |plan_name, service|
  create_plan :application, :name => plan_name, :issuer => service, :published => true, :default => true
end

Given(/^the provider has a (default )?free application plan(?: "([^\"]*)")?$/) do |default, plan_name|
  @free_application_plan ||= create_plan :application, name: plan_name || 'Copper', issuer: @service, published: true, default: default.present?
end

Given(/^the provider has a(nother|\ second|\ third)? (default )?paid (application|service|account) plan(?: "([^\"]*)")?(?: of (\d+) per month)?$/) do |other, default, plan_type, plan_name, cost|
  plan_type_name = (other ? "#{other.strip}_" : '') + plan_type
  return instance_variable_get("@paid_#{plan_type_name}_plan") if instance_variable_defined?("@paid_#{plan_type_name}_plan")
  default_plan_names = {
    'application' => 'Gold',
    'service' => 'Star',
    'account' => 'Premium'
  }
  default_plan_costs = {
    'application' => 100,
    'service' => 10,
    'account' => 1
  }
  plan_name = (plan_name || default_plan_names[plan_type])
  plan = create_plan plan_type.to_sym, name: plan_name, issuer: @service, cost: (cost || default_plan_costs[plan_type]), published: true, default: default.present?
  instance_variable_set("@paid_#{plan_type_name}_plan", plan)
end

Given /^(?:a|an)( default)?( published)? (#{PLANS}) plan "([^\"]*)" (?:of|for) ((?:provider|service) "[^\"]*")(?: for (\d+) monthly)?(?: exists)?$/ do |default, published, type, plan_name, issuer, cost|
  type ||= :application
  create_plan type, :name => plan_name, :issuer => issuer, :cost => cost, :default => default, :published => published
end

Given /^(buyer "[^"]*") signed up for plans? (.+)$/  do |buyer, lst|
  lst.each do |name|
    name = name.strip.delete('"')
    sign_up(buyer, name)
  end
end

Given /^the buyer signed up for provider's paid (application|service|account) plan$/ do |plan_type|
  plan = instance_variable_get("@paid_#{plan_type}_plan")
  sign_up(@buyer, plan.name)
end

Given /^the buyer signed up for plan "([^"]*)"$/ do |plan_name|
  sign_up(@buyer, plan_name)
end

Given /^the buyer changed to plan "([^"]*)"$/ do |plan_name|
  plan = Plan.find_by(name: plan_name)
  @buyer.bought_cinstance.change_plan!(plan)
end


Given /^the buyer's (application|service|account) plan contract is (.*)$/ do |plan_type,state|
  plan = instance_variable_get("@paid_#{plan_type}_plan")
  contract = @buyer.contracts.where(plan_id: plan.id).first!
  contract.update_column(:state, state)
end

Given /^(plan "[^"]*") is (published|hidden)$/ do |plan,state|
  if state == 'published'
    plan.publish! unless plan.published?
  else
    plan.hide! unless plan.hidden?
  end
end

Given /^(#{PLANS} plan "[^\"]*") requires approval(?: of contracts)?$/  do |plan|
  plan.update_attribute :approval_required, true
end

Given /^the application "([^\"]*)" of the partner "([^\"]*)" has a trial period of (\d+) days?$/  do |application_name, buyer_name, days|
  cinstance = @provider.buyers.where(org_name: buyer_name)
      .first.application_contracts.where(name: application_name).first
  cinstance.trial_period_expires_at = Time.zone.now + days.to_i.days
  cinstance.save!
end

Given(/^I want to change the plan of my application to paid$/) do
  steps %(
    Given the buyer logs in to the provider
    And I go to my application page
    And I follow "Edit #{@application.name}"
    And I follow "Change"
    And I follow "#{@paid_application_plan.name}"
  )
end

Given /^master has an? application plan "([^\"]*)"$/ do |plan_name|
  create_plan :application, name: plan_name, issuer: Account.master
end
