# frozen_string_literal: true

Then "I should see the partners submenu" do
  step 'I should see the "links":', table(%(
   | link     |
   | Accounts      |
   | Subscriptions |
   | Export  |
  ))
end

Then "I {should} see menu items" do |visible, items|
  items.raw.each do |item|
    assert visible ? has_css?('li', text: item[0]) : has_no_css?('li', text: item[0])
  end
end

Then "there should be submenu items" do |items|
  items.rows.each do |item|
    within '.secondary-nav-item-pf' do
      assert has_css? 'li', text: item[0]
    end
  end
end

Then "I choose {string} in the sidebar" do |item|
  within '#side-tabs' do
    click_link(item)
  end
end

Then "I should see the help menu items" do |items|
  items.rows.each do |item|
    within '.PopNavigation--docs ul.PopNavigation-list' do
      assert has_css?('li', text: item[0])
    end
  end
end

# TODO: replace this with with more generic step?!
Then "I should still be in the {string}" do |menu_item|
  assert has_css?('li.pf-m-current a', text: menu_item)
end

Then "I {should} see the provider menu" do |visible|
  menu = 'ul#tabs li a'
  assert visible ? has_css?(menu) : has_no_css?(menu)
end

Given "provider {string} has xss protection options disabled" do
  settings = current_account.settings
  settings.cms_escape_draft_html = false
  settings.cms_escape_published_html = false
  settings.save
end
