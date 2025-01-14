# frozen_string_literal: true

Given "a default application plan of {provider}" do |provider|
  FactoryBot.create(:published_application_plan, name: 'The Plan',
                    issuer: provider.first_service!,
                    default: true)
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
