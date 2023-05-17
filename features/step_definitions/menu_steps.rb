# frozen_string_literal: true

Then /^I should see menu sections$/ do |items|
  sections = if features_current_api?
               find_all('#mainmenu > .pf-c-nav__section > .pf-c-nav__list > .pf-c-nav__item > .pf-c-nav__link')
             else
               find_all('#mainmenu > .pf-c-nav__list > .pf-c-nav__item > .pf-c-nav__link')
             end

  assert_equal items.raw.flatten, sections.map(&:text)
end

Then "I should see menu items under {string}" do |section, items|
  button = find('#mainmenu .pf-c-nav__item.pf-m-expandable button.pf-c-nav__link', text: section)
  button.click if button['aria-expanded'] == 'false'

  nav_items = within(button.sibling('.pf-c-nav__subnav')) do
    find_all('.pf-c-nav__item', visible: :all).map { |i| i.text(:all) }
  end

  assert_equal items.raw.flatten, nav_items
end

Then "the help menu should have the following items:" do |table|
  open_help_menu
  assert_same_elements table.raw.flatten, find(help_menu_selector).find_all('ul li').map(&:text)
end

# TODO: replace this with with more generic step?!
Then /^I should still be in the "(.+?)"$/ do |menu_item|
  assert has_css?('.pf-c-nav__item.pf-m-current', text: menu_item)
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
    assert_not has_css? '.pf-c-nav__section-title[title]'
  end
end

def features_current_api?
  has_css?('#mainmenu > .pf-c-nav__section')
end

def help_menu_selector
  'header .PopNavigation.PopNavigation--docs'
end

def open_help_menu
  find("#{help_menu_selector} a", wait: false).click
end
