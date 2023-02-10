# frozen_string_literal: true

When "{provider} has following template" do |provider, string|
  layout = provider.layouts.find_by_system_name('main_layout')
  layout ||= provider.layouts.build(:system_name => 'main_layout')
  layout.draft = string
  layout.publish!
end

Then /^page "(.+?)" should contain$/ do |page_name, string|
  visit(page_name && path_to(page_name) || "/")
  assert_match string, page.body
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
