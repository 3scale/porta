# Account Plans
#
Given /^(provider "[^"]*") allows to change account plan (directly|only with credit card|by request)?$/ do |provider,mode_string|
  mode = change_plan_permission_to_sym(mode_string)
  provider.set_change_account_plan_permission!(mode)
end

Given /^(provider "[^"]*") does not allow to change account plan$/ do |provider|
  provider.set_change_account_plan_permission!(:none)
end


# Application Plans
#
Given /^(service "[^"]*") allows to change application plan (directly|only with credit card|by request|with credit card required)?$/ do |service,mode_string|
  mode = change_plan_permission_to_sym(mode_string)
  service.set_change_application_plan_permission!(mode)
end

Given(/^the provider service allows to change application plan (.*)$/) do |mode|
  step %(service "#{@service.name}" allows to change application plan #{mode})
end

Given /^(service "[^"]*") does not allow to change application plan$/ do |service|
  service.set_change_application_plan_permission!(:none)
end

Given /^(service "[^"]*") allows to choose plan on app creation$/ do |service|
  service.set_change_plan_on_app_creation_permitted!(true)
end



# Service Plans
#
Given /^(provider "[^"]*") allows to change service plan (directly|only with credit card|by request)?$/ do |provider,mode_string|
  mode = change_plan_permission_to_sym(mode_string)
  provider.set_change_service_plan_permission!(mode)
end

