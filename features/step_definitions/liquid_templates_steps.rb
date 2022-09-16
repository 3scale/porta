# frozen_string_literal: true

When "{provider} has following template" do |provider, string|
  layout = provider.layouts.find_by_system_name('main_layout')
  layout ||= provider.layouts.build(:system_name => 'main_layout')
  layout.draft = string
  layout.publish!
end

Then /^page "(.+?)" should be$/ do |page_name, string|
  visit(page_name && path_to(page_name) || "/")
  # page.body.should == string # nicer output, but you guys hate RSpec
  assert_equal string, page.body
end

Then /^page "(.+?)" should contain$/ do |page_name, string|
  visit(page_name && path_to(page_name) || "/")
  assert_match string, page.body
end

Given "a liquid template {string} of {provider} with content" do |name, provider, content|
  provider.layout.build(:name => name, :draft => content).publish!
end

Given "a liquid template {string} of {provider} last updated {}" do |name, provider, time|
  template = provider.layouts.find_by_system_name(name) # I was having some issues with find_or_create
  template ||= provider.layouts.create!( :system_name => name )
  no_nest_travel_to(Time.zone.parse(time)) { template.touch }
end

Then "liquid template {string} of {provider} should be modified" do |name, provider|
  assert_not_nil provider.layouts.find_by_system_name(name)
end

Then "liquid template {string} of {provider} should have body {string}" do |name, provider, body|
  assert_equal body, provider.layouts.find_by_system_name(name).body
end

When "builtin page {string} of {provider} has content {string}" do |system_name, provider, content|
  template = provider.builtin_pages.where(system_name: system_name).first
  template.update_column(:published, content)
end

When "builtin partial {string} of {provider} has content {string}" do |system_name, provider, content|
  template = provider.builtin_partials.where(system_name: system_name).first
  template.update_column(:published, content)
end


Then(/^I should (not )?see markup matching '(.*)'$/) do |invisible,css|
  if invisible
    assert_empty Nokogiri.parse(page.body).css(css), "'@{css}' should not match anything"
  else
    assert_not_empty Nokogiri.parse(page.body).css(css), "'@{css}' should match some elements"
  end
end
