Then /^I should see the partners submenu$/ do
  step 'I should see the "links":', table(%{
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

Then /^I should not see menu items$/ do |items|
  items.raw.each do |item|
    within '#mainmenu' do
      assert has_no_css? 'li', :text => item[0]
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

Then "the help menu should have the following items:" do |table|
  assert_same_elements table.raw.flatten, find_all('.PopNavigation--docs ul.PopNavigation-list li').map(&:text)
end

# TODO: replace this with with more generic step?!
Then %r{^I should still be in the "(.+?)"$} do |menu_item|
  assert has_css?('li.pf-m-current a', :text => menu_item)
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

Then "the name of the product can be seen on top of the menu" do
  within '#mainmenu' do
    assert has_css?('.pf-c-nav__section-title', text: Service.find_by(name: 'API').name)
  end
end

Then "the name of the backend can be seen on top of the menu" do
  within '#mainmenu' do
    assert has_css?('.pf-c-nav__section-title', text: @backend.name)
  end
end

Then /^I should see there is no current API/ do
  within '#mainmenu' do
    assert_not has_css? '.pf-c-nav__section-title'
  end
end

def help_menu_selector
  'header .PopNavigation.PopNavigation--docs'
end

def open_help_menu
  find(help_menu_selector, wait: false).click_link
end
