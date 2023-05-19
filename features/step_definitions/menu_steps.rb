# frozen_string_literal: true

Then /^I should see menu sections$/ do |items|
  sections = page_sidebar.find_all('.pf-c-nav > .pf-c-nav__list > .pf-c-nav__item > .pf-c-nav__link')

  assert_equal items.raw.flatten, sections.map(&:text)
end

Then "I should see menu items under {string}" do |section, items|
  button = page_sidebar.find('.pf-c-nav__item.pf-m-expandable button.pf-c-nav__link', text: section)
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
  within page_sidebar do
    assert has_css?('.pf-c-nav__current-api', text: @provider.default_service.name)
  end
end

Then "the name of the backend can be seen on top of the menu" do
  within page_sidebar do
    assert has_css?('.pf-c-nav__current-api', text: @backend.name)
  end
end

Then /^I should see there is no current API/ do
  within page_sidebar do
    assert_not has_css? '.pf-c-nav__current-api'
  end
end

def features_current_api?
  page_sidebar.has_css?('.pf-c-nav__section')
end

def help_menu_selector
  'header .PopNavigation.PopNavigation--docs'
end

def open_help_menu
  find("#{help_menu_selector} a", wait: false).click
end

def page_sidebar
  find('.pf-c-page__sidebar')
end

def subsection_from_vertical_nav?(section, subsection)
  within page_sidebar do
    anchor = find(:css, '.pf-c-nav__link', text: section)
    click_on(section) unless anchor[:'aria-expanded'] == 'true'
    return has_content?(subsection)
  end
end

def section_from_vertical_nav?(section)
  within page_sidebar do
    return has_content?(section)
  end
end
