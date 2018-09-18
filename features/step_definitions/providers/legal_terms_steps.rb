
Given /^the (buyer "[^\"]*") does not sign legal terms$/ do |buyer|
  buyer.update_attribute :signs_legal_terms, false
end

#tricky since we are not doing proper js test
When /^I do the (buyer "[^\"]*") inmune from signing legal terms$/ do |buyer|
  step "I should see the buyer signs up legal terms"

  put "partners/#{buyer.id}/toggle_signs_legal_terms"
  follow_redirect!
end

When /^I do the (buyer "[^\"]*") sign legal terms$/ do |buyer|
  step "I should see the buyer signs up an external legal terms agreement"

  put "partners/#{buyer.id}/toggle_signs_legal_terms"
  follow_redirect!
end

Then /^I should see the buyer signs up legal terms$/ do
  response.body.should have_regexp /Must click through legal agreements/
end

Then /^I should see the buyer signs up an external legal terms agreement$/ do
  response.body.should have_regexp /Immunity from legal agreements/
end

Then /^I should see no notice about legal terms$/ do
  response.body.should_not have_regexp /Users of this account will not be presented with legal terms and conditions/
end

Then /^I should see a notice saying I do not sign legal terms$/ do
  response.body.should have_regexp /Users of this account will not be presented with legal terms and conditions/
end
