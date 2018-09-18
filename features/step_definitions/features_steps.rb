Given /^a feature "([^\"]*)" of (provider "[^\"]*")$/ do |feature_name, provider|
  provider.default_service.features.create!(:name => feature_name)
end

Given /^feature "([^\"]*)" is (visible|hidden)$/ do |feature_name, visibility|
  feature = Feature.find_by_name!(feature_name)
  feature.visible = (visibility == 'visible')
  feature.save!
end

Given /^feature "([^\"]*)" is (enabled|disabled) for (plan "[^"]*")$/ do |feature_name, state, plan|
  #FIXME: if the feature does not exist this blows!
  feature = plan.service.features.find_by_name!(feature_name)

  if state == 'enabled'
    plan.features << feature
  else
    plan.features.delete(feature)
  end
end

When /^I press the (enable|disable) button for feature "([^"]*)"$/ do |state, name|
  button = find(%(table#features td:contains("#{name}") ~ td form input[type=image]))
  button.click
end

When /^I (follow|press) "([^"]*)" for (feature "[^"]*")$/ do |action, label, feature|
  step %(I #{action} "#{label}" within "##{dom_id(feature)}")
end

Then /^feature "([^"]*)" should be (enabled|disabled) for (plan "[^"]*")$/ do |name, state, plan|
  assertion = state == 'enabled' ? :assert_not_nil : :assert_nil

  send(assertion, plan.features.find_by_name(name))
end

Then /^I should see (enabled|disabled) feature "([^"]*)"$/ do |state, name|
  assert has_css?(%(table#features tr.#{state} td:contains("#{name}")))
end

Then /^I should see feature "([^"]*)"$/ do |name|
  assert has_css?(%(table#features td:contains("#{name}")))
end

Then /^I should not see feature "([^"]*)"$/ do |name|
  assert has_no_css?(%(table#features td:contains("#{name}")))
end


Then /^(provider "[^"]*") should not have feature "([^"]*)"$/ do |provider, name|
  assert_nil provider.default_service.features.find_by_name(name)
end
