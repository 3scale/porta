# frozen_string_literal: true

Given "a feature {string} of {provider}" do |feature_name, provider|
  provider.default_service.features.create!(name: feature_name)
end

Given "feature {string} is {visible}" do |feature_name, visible|
  feature = Feature.find_by!(name: feature_name)
  feature.visible = visible
  feature.save!
end

Given "feature {string} is {enabled} for plan {string}" do |feature_name, enabled, plan|
  feature = plan.service.features.find_by!(name: feature_name)

  if enabled
    plan.features << feature
  else
    plan.features.delete(feature)
  end
end

When "I press the enabled/disable button for feature {string}" do |name|
  button = find(%(table#features td:contains("#{name}") ~ td form input[type=image]))
  button.click
end

When "I {word} {string} for {feature}" do |action, label, feature|
  step %(I #{action} "#{label}" within "##{dom_id(feature)}")
end

Then "feature {string} should be {enabled} for {plan}" do |name, enabled, plan|
  assert_equal enabled, plan.features.find_by(name: name).nil?
end

Then "I should see {word} feature {string}" do |state, name|
  assert has_css?(%(table#features tr.#{state} td:contains("#{name}")))
end

Then "I {should} see feature {string}" do |visible, name|
  assert_equal visible, has_css?(%(table#features td:contains("#{name}")))
end

Then "{provider} should not have feature {string}" do |provider, name|
  assert_nil provider.default_service.features.find_by(name: name)
end
