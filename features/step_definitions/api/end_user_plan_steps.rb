Given /^an end user plan "(.+?)" of (provider ".+?")$/ do |name, provider|
  service = provider.first_service!
  Factory(:end_user_plan, :service => service, :name => name)
end

Then /^"(.*?)" should be default end user plan for service "(.*?)"$/ do |plan_name, service_name|
  service = Service.where(name: service_name).first
  plan    = EndUserPlan.where(name: plan_name).first
  assert_equal service.default_end_user_plan, plan
end

Then(/^there should not be any mention of end user plans$/) do
  assert has_no_content?("End User Plans")
  assert has_no_content?("end user plans")
end
