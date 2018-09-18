Then(/^there should not be any mention of service plans$/) do
  assert has_no_content?("Service Plans")
  assert has_no_content?("service plans")
  assert has_no_content?("Service plan")
end