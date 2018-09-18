Given /^(the forum of "[^\"]*") have topics$/ do |forum|
  Factory(:topic, :forum => forum, :user => forum.account.users.first)
end

Given /^(the forum of "[^"]*") has topics? #{QUOTED_LIST_PATTERN}$/ do |forum, titles|
  user = forum.account.admins.first

  titles.each do |item|
    Factory(:topic, :forum => forum, :title => item, :user => user)
  end
end

Given /^(the forum of "[^"]*") has topic "([^"]*)" with "([^"]*)"$/ do |forum, title, body|
  Factory(:topic, :forum => forum,
                  :title => title,
                  :body  => body,
                  :user  => forum.account.admins.first)
end

Given /^(the forum of "[^"]*") has topic "([^"]*)" from (user "[^"]*")$/ do |forum, title, user|
  Factory(:topic, :forum => forum, :title => title, :user => user)
end

Given /^(the forum of "[^"]*") has topic "([^"]*)" from (user "[^"]*") created (.*)$/ do |forum, title, user, time|
  Timecop.travel(Chronic.parse(time)) do
    Factory(:topic, :forum => forum, :title => title, :user => user)
  end
end

Given /^(the forum of "[^"]*") has topic "([^"]*)" in category "([^"]*)"$/ do |forum, title, category_name|
  Factory(:topic, :forum    => forum,
                  :category => forum.categories.find_by_name!(category_name),
                  :title    => title,
                  :user     => forum.account.admins.first)
end

Given /^(the forum of "[^"]*") has the following topics:$/ do |forum, table|
  table.hashes.each do |hash|
    category = TopicCategory.find_by_name(hash['Category'])

    user = if hash['Owner']
             User.find_by_username!(hash['Owner'])
           else
             forum.account.users.first
           end

    created_at = hash['Created at'] || 'now'

    Timecop.travel(Chronic.parse(created_at)) do
      topic = Factory(:topic, :forum    => forum,
                              :title    => hash['Topic'],
                              :tag_list => hash['Tags'],
                              :user     => user,
                              :category => category,
                              :sticky   => hash['Sticky?'] == 'yes')

      # We are creating topics with more that one post, since last post deletion
      # deletes also the topic.
      Factory(:post, :topic => topic, :user => user)
    end
  end
end

When /^I create a new topic "([^\"]*)"$/ do |topic|
  step %(I go to the new topic page)
  step %(I fill in "Title" with "#{topic}")
  step %(I fill in "Body" with "Bla bla bla")
  step %(I press "Create thread")
end

When /^the (user "[^"]*") post in the topic in (the forum of "[^"]*")$/ do |user, forum|
  Factory(:post, :topic => forum.topics.first, :forum => forum, :user => user)
end

Then /^(the forum of "[^"]*") should have topic "([^"]*)"$/ do |forum, title|
  assert_not_nil forum.topics.find_by_title(title)
end

Then /^(the forum of "[^"]*") should not have topic "([^"]*)"$/ do |forum, title|
  assert_nil forum.topics.find_by_title(title)
end

Then /^(the forum of "[^"]*") should have topic "([^"]*)" in category "([^"]*)"$/ do |forum, title, category|
  topic = forum.topics.find_by_title(title)
  assert_not_nil topic
  assert_equal category, topic.category.try!(:name)
end

Then /^(the forum of "[^"]*") should have sticky topic "([^"]*)"$/ do |forum, title|
  topic = forum.topics.find_by_title(title)
  assert_not_nil topic
  assert topic.sticky?
end

Then /^(the forum of "[^"]*") should have non\-sticky topic "([^"]*)"$/ do |forum, title|
  topic = forum.topics.find_by_title(title)
  assert_not_nil topic
  assert !topic.sticky?
end

Then /^I should see the first topic is "([^"]*)"$/ do |topic|
  topics = all('table tr.topic')
  assert topics.first.has_css?(%(td:contains("#{topic}")))
end


When /^I leave the obligatory topic fields blank$/ do
  fill_in "topic_title", :with => ""
  fill_in "Body", :with => ""
end


Then /^I should see all the topics on the (forum of "[^\"]*")$/ do |forum|
  step %{I should see "#{forum.topics.length} topics"}
  forum.topics.each do |topic|
    step %{I should see "#{topic.title}"}
  end
end

Then /^I should see only the (\w+) topic$/ do |title|
  step %{I should see "1 topic"}
  step %{I should see "#{title}"}
end

Then /^I should see topics? #{QUOTED_LIST_PATTERN}$/ do |titles|
  titles.each do |title|
    assert has_css?('tr.topic', :text => title)
  end
end

Then /^I should not see topics? #{QUOTED_LIST_PATTERN}$/ do |titles|
  titles.each do |title|
    assert has_no_css?('tr.topic', :text => title)
  end
end

Then /^the topic should not be destroyed$/ do
  @topic.reload.should_not be_nil
end

Then /^the topic should be destroyed$/ do
  expect { @topic.reload }.to raise_error ActiveRecord::RecordNotFound
end

When /^I do a HTTP request to update (topic "[^"]*")$/ do |topic|
  page.driver.browser.process :put, forum_topic_path(topic)
end

When /^I do a HTTP request to delete (topic "[^"]*")$/ do |topic|
  page.driver.browser.process :delete, forum_topic_path(topic)
end

When /^I do a HTTP request to create a sticky topic "([^"]*)"$/ do |title|
  page.driver.browser.process :post, forum_topics_path, :topic => {:title  => title,
                                                 :body   => 'Blah blah',
                                                 :sticky => 1}
  # page.driver.browser.follow_redirects!
end

Then /^I should see the link to create new topic$/ do
  step 'I should see "Start new thread"'
end

Then /^I should not see the link to create new topic$/ do
  step 'I should not see "Start new thread"'
end
