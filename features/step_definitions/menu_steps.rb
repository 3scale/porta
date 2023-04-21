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

Then "the help menu should have the following items:" do |table|
  assert_same_elements table.raw.flatten, find_all('.PopNavigation--docs ul li').map(&:text)
end

# TODO: replace this with with more generic step?!
Then %r{^I should still be in the "(.+?)"$} do |menu_item|
  assert has_css?('li.pf-m-current a', :text => menu_item)
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
  find("#{help_menu_selector} a", wait: false).click
end
