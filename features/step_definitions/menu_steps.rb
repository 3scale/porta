# frozen_string_literal: true

Then "the sidebar should have (only )the following section(s):" do |items|
  sections = page_sidebar.find_all('.pf-c-nav > .pf-c-nav__list > .pf-c-nav__item > .pf-c-nav__link')

  assert_equal items.raw.flatten, sections.map(&:text)
end

Then "the sidebar should have the following item(s) in section {string}:" do |section, items|
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

Then "the sidebar should not display a current API" do
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

def help_menu_selector
  'header .pf-c-dropdown[title="Documentation"]'
end

def open_help_menu
  find("#{help_menu_selector} .pf-c-dropdown__toggle", wait: false).click
end
