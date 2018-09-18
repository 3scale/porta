Then /^I should be denied the access$/ do
  # assert has_content?('Access Denied')
  assert_equal 403, page.status_code
end

