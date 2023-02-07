# frozen_string_literal: true

Given "{topic} has only one post" do |topic|
  topic.posts[1..-1].each(&:destroy)
  assert_equal 1, topic.posts.count
end

Given "{topic} has {int} posts" do |topic, number|
  if topic.posts.count > number
    topic.posts[number..-1].each(&:destroy)
  elsif topic.posts.count < number
    (number - topic.posts.count).times { FactoryBot.create(:post, :topic => topic) }
  end
end

Then "{topic} should have {int} post(s)" do |topic, number|
  assert number, topic.posts.count.to_s
end

Then "{topic} should have post {string}" do |topic, body|
  assert_not_nil(topic.posts.to_a.find { |post| post.body == body })
end

Then "{topic} should not have post {string}" do |topic, body|
  assert_nil(topic.posts.to_a.find { |post| post.body == body })
end

Given "{user} posted {string} {today} under {topic}" do |user, body, time, topic|
  safe_travel_to(Chronic.parse(time)) do
    FactoryBot.create(:post, :user => user, :topic => topic, :body => body)
  end
end

Given "{forum} has the following posts:" do |forum, table|
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

Then /^(.+) for post "([^"]*)"$/ do |lstep, body|
  post = Post.find_by!(body: body)
  within "##{dom_id(post)}" do
    step lstep
  end
end

Then /^(.+) for the last post under topic "([^"]*)"$/ do |lstep, topic_title|
  post = Topic.find_by!(title: topic_title).posts.last
  within "##{dom_id(post)}" do
    step lstep
  end
end
