
# frozen_string_literal: true

When /^I reply to topic "([^\"]*)" with "([^"]*)"$/ do |topic_title, body|
  step %(I go to the "#{topic_title}" topic page)
  step %(I fill in "Body" with "#{body}")
  step %(I press "Post reply")
end

Then /^I should see the page to edit the post$/ do
  response.should have_text(/Edit Post/)
end

Then /^I should not see the page to edit the post$/ do
  response.should_not have_text(/Edit Post/)
end

Then /^I should be redirected to latest post for topic "(.*)"$/ do |topic_title|
  topic = Topic.find_by_title! topic_title
  response.should redirect_to(whitelabel_forum_topic_path(topic, :anchor => "post_#{topic.posts.last.id}"))
  follow_redirect!
end


Then /^the post should not be destroyed$/ do
  @post.reload.should_not be_nil
end

Then /^the post should be destroyed$/ do
  expect { @post.reload }.to raise_error ActiveRecord::RecordNotFound
end

Then /^I should see post dates in the right date format$/ do
  @topic.posts.each do |post|
    response.should have_tag("p", /#{post.updated_at.to_s(:long)}/)
  end
end

Then /^I should see "([^\"]*)" is the last post on the topic$/ do |text|
  response.should have_tag('p', /#{text}/)
end

Then /^I should not see the post has been removed$/ do
  response.body.should_not have_regexp /This post has been removed/
end

Given /^(topic "[^\"]*") has only one post$/ do |topic|
  topic.posts[1..-1].each(&:destroy)
  assert_equal 1, topic.posts.count
end

Given /^(topic "[^"]*") has (\d+) posts$/ do |topic, number|
  number = number.to_i

  if topic.posts.count > number
    topic.posts[number..-1].each(&:destroy)
  elsif topic.posts.count < number
    (number - topic.posts.count).times { FactoryBot.create(:post, :topic => topic) }
  end
end

Then /^(topic "[^"]*") should have (\d+) posts?$/ do |topic, number|
  assert number, topic.posts.count.to_s
end

Then /^(topic "[^"]*") should have post "([^"]*)"$/ do |topic, body|
  assert_not_nil(topic.posts.to_a.find { |post| post.body == body })
end

Then /^(topic "[^"]*") should not have post "([^"]*)"$/ do |topic, body|
  assert_nil(topic.posts.to_a.find { |post| post.body == body })
end

Given /^a post "([^"]*)" under (topic "[^"]*")$/ do |body, topic|
  FactoryBot.create(:post, :user => topic.user, :topic => topic, :body => body)
end

Given /^(user "[^"]*") posted "([^"]*)" (today|yesterday) under (topic "[^"]*")$/ do |user, body, time, topic|
  Timecop.travel(Chronic.parse(time)) do
    FactoryBot.create(:post, :user => user, :topic => topic, :body => body)
  end
end

Given /^(the forum of "[^"]*") has the following posts:$/ do |forum, table|
  table.hashes.each do |hash|
    topic = forum.topics.find_by_title!(hash['Topic'])
    user  = User.find_by_username!(hash['User'])

    FactoryBot.create(:post, :user => user, :topic => topic, :body => hash['Body'])
  end
end

Then /^I should see post "([^"]*)"$/ do |body|
  assert has_css?('.post', :text => body)
end

Then /^I should not see post "([^"]*)"$/ do |body|
  assert has_no_css?('.post', :text => body)
end

Then /^I should see an anonymous post "([^"]*)"$/ do |body|
  elements = all('.post').select do |element|
    element.has_css?('.topicAuthor', :text => 'Anonymous') &&
    element.has_content?(body)
  end

  assert !elements.empty?
end

Then /^I should not see post "([^"]*)" by "([^"]*)"$/ do |body, author|
  elements = all('.post').select do |element|
    element.has_css?('.topicAuthor', :text => author) &&
    element.has_content?(body)
  end

  assert elements.empty?
end

Then /^(.+) for (post "[^"]*")$/ do |lstep, post|
  within "##{dom_id(post)}" do
    step lstep
  end
end

Then /^(.+) for (the last post under topic "[^"]*")$/ do |lstep, post|
  within "##{dom_id(post)}" do
    step lstep
  end
end

When /^I do a HTTP request to update (post "[^"]*")$/ do |post|
  page.driver.browser.process :put, forum_post_path(post)
end

When /^I do a HTTP request to delete (post "[^"]*")$/ do |post|
  page.driver.browser.process :delete, forum_post_path(post)
end
