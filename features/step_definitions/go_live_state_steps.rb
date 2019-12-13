When(/^I complete the "(.*?)" step$/) do |step|
  current_account.go_live_state.advance(step)
end

Then(/^I should be done$/) do
  assert page.has_no_css?('#rinse-repeat.hide')
end

Then(/^the "(.*?)" step should look done$/) do |step|
  assert page.has_css?("##{step}.done")
end
