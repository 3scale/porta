# frozen_string_literal: true

When "I visit the forum page with no tag" do
  step "I go to the forum page"
end

When "I visit the forum page with tag {string}" do |tag|
  visit "/#{tag}/forum"
end

Then "I should see the tags of the topic" do
  response.body.should have_text /#{@topic.tags.map(&:name).join('\s+')}/
end

#TODO: check if this step is still valid
# TODO: commented for testing purposes. I all is still green, remove it
# Then "I should see the tags" do
  # topic = Topic.last
  # topic.tags.should_not be_empty
  # step %(I should see "#{topic.tags.map(&:names).join(' ')}")
# end
