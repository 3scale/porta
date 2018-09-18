When /^I request the url to edit the first topic on the (forum of "[^\"]*")$/ do |forum|
  visit edit_admin_forum_topic_path(forum.topics.first)
end

When /^I request the url to edit the topic "([^\"]*)" on the (forum of "[^\"]*")$/ do |title, forum|
  @topic = forum.topics.find_by_title(title)
  visit edit_admin_forum_topic_path(@topic)
end

When /^I request the url of the forum subscriptions page$/ do
  visit forum_subscriptions_path
end

When /^I request the url to destroy the first topic on the (forum of "[^\"]*")$/ do |forum|
  @topic = forum.topics.first
  visit admin_forum_topic_path(@topic), :delete
end

When /^I request the url to destroy the topic "([^\"]*)" on the (forum of "[^\"]*")$/ do |title, forum|
  @topic = forum.topics.find_by_title title
  visit admin_forum_topic_path(@topic), :delete
end

#TODO: check if this step is used still
#TODO differentiate when accessing public or admin side of pages
# this one is of course accessing the public side
