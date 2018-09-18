When(/^I submit a mapping rule with an empty pattern$/) do
  step %{I toggle "Mapping Rules"}
  click_on 'add-proxy-rule'
  click_on 'proxy-button-save-and-deploy'
end

Then(/^it should be clear the proxy configuration is erroneous$/) do
  assert_text(:visible, "Couldn't update the Staging Configuration")
  assert_text(:visible, "There seems to be an error in your Staging Configuration. Please review, fix and re-submit.")
end

