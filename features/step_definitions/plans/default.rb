# frozen_string_literal: true

Given "{plan} is {default}" do |plan, default|
  unless default
    assert !default_plan?(plan)
  else
    make_plan_default(plan)
  end
end

Given "a default {word} plan of {provider}" do |type, provider|
  create_plan(type, name: 'The Plan', issuer: provider, published: true, default: true)
end

Given "a default {word} {string} plan of {provider}" do |type, name, provider|
  create_plan(type, name: name, issuer: provider, published: true, default: true)
end

Given "{provider} has no default application plan" do |provider|
  provider.services.each do |service|
    service.update_attribute :default_application_plan, nil
  end
end

Given "{provider} has default service and account plan" do |provider|
  service = provider.first_service!
  service.publish!
  provider.update_attribute( :default_account_plan, provider.account_plans.first)

  plans = service.service_plans
  plans.default!(plans.default_or_first || plans.first)
end
