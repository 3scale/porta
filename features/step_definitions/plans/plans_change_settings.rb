# frozen_string_literal: true

Given "{provider} allows to change account plan {plan_permission}" do |provider, plan_permission|
  provider.set_change_account_plan_permission! plan_permission
end

Given "{provider} does not allow to change account plan" do |provider|
  provider.set_change_account_plan_permission!(:none)
end

Given "the provider service allows to change application plan {plan_permission}" do |plan_permission|
  @provider.default_service.set_change_application_plan_permission! plan_permission
end

Given "{service} allows to choose plan on app creation" do |service|
  service.set_change_plan_on_app_creation_permitted!(true)
end

Given "{provider} allows to change service plan {plan_permission}" do |provider, plan_permission|
  provider.set_change_service_plan_permission! plan_permission
end
