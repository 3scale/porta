# frozen_string_literal: true

Given "the forum of {forum} have topics" do |forum|
  FactoryBot.create(:topic, forum: forum, user: forum.account.users.first)
end

Given "the forum of {forum} has topics? #{QUOTED_LIST_PATTERN}" do |forum, titles|
  user = forum.account.admins.first

  titles.each do |item|
    FactoryBot.create(:topic, forum: forum, title: item, user: user)
  end
end

Given "the forum of {forum} has topic {string} with {string}" do |forum, title, body|
  FactoryBot.create(:topic, forum: forum, title: title, body: body, user: forum.account.admins.first)
end

Given "the forum of {string} has topic {string} from user {user}" do |forum, title, user|
  FactoryBot.create(:topic, forum: forum, title: title, user: user)
end

Given "the forum of {string} has topic {string} from user {user} created {}" do |forum, title, user, time|
  Timecop.travel(Chronic.parse(time)) do
    FactoryBot.create(:topic, forum: forum, title: title, user: user)
  end
end

Given "the forum of {forum} has topic {string} in category {string}" do |forum, title, category_name|
  FactoryBot.create(:topic, forum: forum, category: forum.categories.find_by!(name: category_name), title: title, user: forum.account.admins.first)
end

Given "the forum of {forum} has the following topics" do |forum, table|
  table.hashes.each do |hash|
    category = TopicCategory.find_by!(name: hash['Category'])

    user = if hash['Owner']
             User.find_by!(username: hash['Owner'])
           else
             forum.account.users.first
           end

    created_at = hash['Created at'] || 'now'

    Timecop.travel(Chronic.parse(created_at)) do
      topic = FactoryBot.create(:topic, forum: forum,
                                        title: hash['Topic'],
                                        tag_list: hash['Tags'],
                                        user: user,
                                        category: category,
                                        sticky: hash['Sticky?'] == 'yes')

      # We are creating topics with more that one post, since last post deletion
      # deletes also the topic.
      FactoryBot.create(:post, topic: topic, user: user)
    end
  end
end

When "I create a new topic {string}" do |topic|
  step %(I go to the new topic page)
  step %(I fill in "Title" with "#{topic}")
  step %(I fill in "Body" with "Bla bla bla")
  step %(I press "Create thread")
end

When "the user {user} post in the topic in the forum of {forum}" do |user, forum|
  FactoryBot.create(:post, topic: forum.topics.first, forum: forum, user: user)
end

Then "the forum of {forum} should have topic {string}" do |forum, title|
  assert_not_nil forum.topics.find_by!(title: title)
end

Then "the forum of {forum} should not have topic {string}" do |forum, title|
  assert_nil forum.topics.find_by!(title: title)
end

Then "the forum of {forum} should have topic {string} in category {string}" do |forum, title, category|
  topic = forum.topics.find_by!(title: title)
  assert_not_nil topic
  assert_equal category, topic.category&.name
end

Then "the forum of {forum} should have sticky topic {string}" do |forum, title|
  topic = forum.topics.find_by!(title: title)
  assert_not_nil topic
  assert topic.sticky?
end

Then "the forum of {forum} should have non\-sticky topic {string}" do |forum, title|
  topic = forum.topics.find_by!(title: title)
  assert_not_nil topic
  assert !topic.sticky?
end

Then /^I should see the first topic is "([^"]*)"$/ do |topic|
  topics = all('table tr.topic')
  assert topics.first.has_xpath?("//a[text()[contains(.,'#{topic}')]]")
end

When /^I leave the obligatory topic fields blank$/ do
  fill_in 'topic_title', with: ''
  fill_in 'Body', with: ''
end

Then "I should see all the topics on the forum of {forum}" do |forum|
  step %(I should see "#{forum.topics.length} topics")
  forum.topics.each do |topic|
    step %(I should see "#{topic.title}")
  end
end

Then /^I should see only the (\w+) topic$/ do |title|
  step %(I should see "1 topic")
  step %(I should see "#{title}")
end

Then /^I should see topics? #{QUOTED_LIST_PATTERN}$/ do |titles|
  titles.each do |title|
    assert has_css?('tr.topic', text: title)
  end
end

Then /^I should not see topics? #{QUOTED_LIST_PATTERN}$/ do |titles|
  titles.each do |title|
    assert has_no_css?('tr.topic', text: title)
  end
end

Then /^the topic should not be destroyed$/ do
  @topic.reload.should_not be_nil
end

Then /^the topic should be destroyed$/ do
  expect { @topic.reload }.to raise_error ActiveRecord::RecordNotFound
end

Then /^I should see the link to create new topic$/ do
  step 'I should see "Start new thread"'
end

Then /^I should not see the link to create new topic$/ do
  step 'I should not see "Start new thread"'
end
