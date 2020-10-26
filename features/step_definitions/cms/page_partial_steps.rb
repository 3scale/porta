# frozen_string_literal: true

Given "{provider} has page partials" do |provider|
  FactoryBot.create :page_partial, account: provider
end

Given "the partial {string} of {provider} is" do |name, provider, body|
  FactoryBot.create(:cms_partial, system_name: name, provider: provider, draft: body).publish!
end

When "I create a bcms page partial" do
  visit cms_page_partials_path
  click_link 'Add'

  fill_in 'Name', with: 'Name'

  submit_partial
end

When "I update a page partial" do
  visit cms_page_partials_path
  select_partial
  click_button 'Edit'

  fill_in 'Name', with: 'new page partial'
  submit_partial

  sleep 0.5
end

When "I delete a page partial" do
  visit cms_page_partials_path
  select_partial
  click_button 'Delete'

  sleep 0.5
end

Then "I should see my page partial(s)" do
  current_account.page_partials.each do |partial|
    assert has_xpath? partial_xpath(partial.id)
  end
end

Then "I should see the page partial changed" do
  assert_equal 'new page partial', current_account.page_partials.first.name
end

Then "I should see no page partials" do
  step %(I should see the page partial was deleted)
end

Then "I should see the page partial was deleted" do
  PageTemplate.all.each do |partial|
    assert has_no_xpath? partial_xpath(partial.id)
  end
end

def submit_partial
  find(:xpath, ".//input[@id='page_partial_submit']").click
end

def select_partial
  find(:xpath, partial_xpath(current_account.page_partials.first.id))
end

def partial_xpath(id)
  ".//tr[@id='page_partial_#{id}']"
end
