Then /^I should see the partners submenu$/ do
  step 'I should see the "links" in the submenu:', table(%{
   | link     |
   | Accounts      |
   | Subscriptions |
   | Export  |
  })
end

Then /^I should see menu items$/ do |items|
  items.raw.each do |item|
    within '#mainmenu' do
      assert has_css? 'li', :text => item[0]
    end
  end
end


Then /^there should be submenu items$/ do |items|
  items.rows.each do |item|
    within '.secondary-nav-item-pf' do
      assert has_css? 'li', :text => item[0]
    end
  end
end

Then /^I choose "(.*?)" in the sidebar$/ do |item|
  within '#side-tabs' do
    click_link(item)
  end
end


Then /^I should see the help menu items$/ do |items|
  items.rows.each do |item|
    within '.PopNavigation--docs ul.PopNavigation-list' do
      assert has_css?('li', :text => item[0])
    end
  end
end

# TODO: replace this with with more generic step?!
Then %r{^I should still be in the "(.+?)"$} do |menu_item|
  assert has_css?('li.active a', :text => menu_item)
end

Then /^I should( not)? see the provider menu$/ do |negative|
  menu = 'ul#tabs li a'
  assert negative ? has_no_css?(menu) : has_css?(menu)
end


Given(/^provider "(.*?)" has xss protection options disabled$/) do |arg1|
  settings = current_account.settings
  settings.cms_escape_draft_html = false
  settings.cms_escape_published_html = false
  settings.save
end
