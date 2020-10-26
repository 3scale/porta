# frozen_string_literal: true

Given "{provider} has no layouts" do |provider|
  assert provider.page_templates.empty?
end

When "I create a bcms layout" do
  visit cms_page_templates_path
  click_link 'Add'

  fill_in 'Name', with: 'name'

  find(:xpath, ".//input[@id='page_template_submit']").click
end

When "I update a layout" do
  visit cms_page_templates_path
  click_template(current_account.page_templates.first.id)
  find(:xpath, ".//a[@id='edit_button']").click

  fill_in 'Name', with: 'new layout'
  find(:xpath, ".//input[@id='page_template_submit']").click

  sleep 0.5
end

When "I delete a layout" do
  visit cms_page_templates_path
  click_template(current_account.page_templates.first.id)
  find(:xpath, ".//a[@id='delete_button']").click

  sleep(0.5)
end

def page_template(id)
  ".//tr[@id='page_template_#{id}']"
end

def click_template(id)
  page_template(id).click
end

Then "I should see my layouts" do
  current_account.page_templates.each do |layout|
    assert has_xpath? page_template(layout.id)
  end
end

Then "I should see my layout" do
  layout = current_account.page_templates.first
  assert has_xpath? page_template(layout.id)
end

Then "I should see the layout changed" do
  assert_equal 'new layout', current_account.page_templates.first.name
end

Then "I should see no layouts" do
  step %(I should see the layout was deleted)
end

Then "I should see the layout was deleted" do
  PageTemplate.all.each do |layout|
    assert has_no_xpath? page_template(layout.id)
  end
end
