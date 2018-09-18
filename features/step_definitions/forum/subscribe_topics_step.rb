Given /^(user "[^\"]*") is subscribed to the topic in (the forum of "[^\"]*")$/ do |user, forum|
  user.user_topics.create! :topic => forum.topics.first
end

Given /^the (user "[^\"]*") is subscribed to the topics:$/ do |user, table|
  table.hashes.each do |hash|
    user.user_topics.create! :topic => Topic.find_by_title(hash['topic'])
  end
end

#FIXME: forum complexity because of reusing everything!
# These ugly steps are needed due to the crazy forum using the same views and routes for both public and admin sides
When /^(user "[^\"]*") subscribe to the topic in (the forum of "[^\"]*")$/ do |user, forum|
  user.user_topics.create! :topic => forum.topics.first
  step %{I navigate to a topic in the forum of "#{user.provider_account.org_name}"}
end

When /^I follow the link to my subscriptions to topics$/ do
  click_link 'My subscriptions'
end

Then /^I should see the link to subscribe to topic$/ do
  assert has_css?('a', :text => /Subscribe to thread/)
end

Then /^I should see that I am subscribed to the topic$/ do
  assert has_content?("You're subscribed for email updates to this thread")
end

Then /^I should see the link to unsubscribe to topic$/ do
  assert has_button?('Unsubscribe')
end

Then /^I unsubscribe the topic$/ do
  click_button('Unsubscribe')
end

Then /^the (user "[^\"]*") should receive an email notifying of the new post$/ do |user|
  step %{"#{user.email}" should receive an email with subject "New post in topic"}
end

Then /^the (user "[^\"]*") should not receive an email notifying of the new post$/ do |user|
  step %{"#{user.email}" should receive no email with subject "New post in topic"}
end

Then /^I should see the topics I follow:$/ do |table|
  table.hashes.each do |hash|
    assert has_css?('a', :text => /#{hash['topic']}/)
  end
end

Then /^I should not see the topics I do not follow:$/ do |table|
  table.hashes.each do |hash|
    assert has_no_css?('a', :text => /#{hash['topic']}/)
  end
end
