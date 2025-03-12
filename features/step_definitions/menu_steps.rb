# frozen_string_literal: true

Then /^(?:|I |they )should see menu sections$/ do |items|
  sections = page_sidebar.find_all('.pf-c-nav > .pf-c-nav__list > .pf-c-nav__item > .pf-c-nav__link')

  assert_equal items.raw.flatten, sections.map(&:text)
end

Then "(I )(they )should see menu items under {string}" do |section, items|
  button = page_sidebar.find('.pf-c-nav__item.pf-m-expandable button.pf-c-nav__link', text: section)
  button.click if button['aria-expanded'] == 'false'

  nav_items = within(button.sibling('.pf-c-nav__subnav')) do
    find_all('.pf-c-nav__item:not(.pf-m-expandable)', visible: :all).map { |i| i.text(:all) }
  end

  assert_equal items.raw.flatten, nav_items
end

Then "the help menu should have the following items:" do |table|
  open_help_menu
  assert_same_elements table.raw.flatten, find(help_menu_selector).find_all('ul li').map(&:text)
end

# TODO: replace this with with more generic step?!
Then /^I should still be in the "(.+?)"$/ do |menu_item|
  assert_selector(:css, '.pf-c-nav__item.pf-m-current', text: menu_item)
end

Then "the name of the product can be seen on top of the menu" do
  within page_sidebar do
    assert_selector(:css, '.pf-c-nav__current-api', text: @provider.default_service.name)
  end
end

Then "the name of the backend can be seen on top of the menu" do
  within page_sidebar do
    assert_selector(:css, '.pf-c-nav__current-api', text: @backend.name)
  end
end

Then /^I should see there is no current API/ do
  within page_sidebar do
    assert_not has_css? '.pf-c-nav__current-api'
  end
end

Given "the sidebar navigation is not collapsible" do
  assert_not has_css?('.pf-c-masthead [data-ouia-component-id="show_hide_menu"]')
end

Given "the sidebar navigation is collapsible" do
  sidebar = page_sidebar
  assert sidebar[:class].match?('.pf-m-expanded')
  assert_not sidebar[:class].match?('.pf-m-collapsed')

  find('.pf-c-masthead [data-ouia-component-id="show_hide_menu"]').click
  assert_not sidebar[:class].match?('.pf-m-expanded')
  assert sidebar[:class].match?('.pf-m-collapsed')
end

def features_current_api?
  page_sidebar.has_css?('.pf-c-nav__section')
end

def help_menu_selector
  'header .pf-c-dropdown[title="Documentation"]'
end

def open_help_menu
  find("#{help_menu_selector} .pf-c-dropdown__toggle", wait: false).click
end

def page_sidebar
  find('.pf-c-page__sidebar')
end
