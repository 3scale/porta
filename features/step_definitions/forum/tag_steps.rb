When /^I visit the forum page with no tag$/ do
  step "I go to the forum page"
end

When /^I visit the forum page with tag "([^\"]*)"$/ do |tag|
  visit "/#{tag}/forum"
end

Then /^I should see the tags of the topic$/ do
  response.body.should have_text /#{@topic.tags.map(&:name).join('\s+')}/
end

#TODO: check if this step is still valid
Then /^I should see the tags$/ do
  topic = Topic.last
  topic.tags.should_not be_empty
  step %{I should see "#{topic.tags.map(&:names).join(' ')}"}
end

