Then /^I should not see the link credit card details$/ do
    assert has_no_xpath?(".//a[text()='Credit Card Details']")
end
