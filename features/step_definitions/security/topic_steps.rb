# frozen_string_literal: true

When "I request the url to edit the first topic on the forum of {forum}" do |forum|
  visit edit_admin_forum_topic_path(forum.topics.first)
end

When "I request the url to edit the topic {string} on the forum of {forum}" do |title, forum|
  @topic = forum.topics.find_by!(title: title)
  visit edit_admin_forum_topic_path(@topic)
end

When "I request the url of the forum subscriptions page" do
  visit forum_subscriptions_path
end

When "I request the url to destroy the first topic on the forum of {forum}" do |forum|
  @topic = forum.topics.first
  visit admin_forum_topic_path(@topic), :delete
end

When "I request the url to destroy the topic {string} on the forum of {forum}" do |title, forum|
  @topic = forum.topics.find_by!(title: title)
  visit admin_forum_topic_path(@topic), :delete
end
