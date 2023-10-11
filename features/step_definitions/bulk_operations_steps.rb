# frozen_string_literal: true

When /^item "(.+?)" is (un)?selected$/ do |name, unselect|
  find('tbody td', text: name)
    .find(:xpath, '..')
    .find('.select input[type="checkbox"]')
    .set(unselect.nil?)
end

When /^they (un)?select all items in the table$/ do |unselect|
  if has_css?('.pf-c-toolbar .pf-m-bulk-select')
    bulk_select(unselect ? :none : :page)
  else
    # DEPRECATED: remove when all tables use PF4 toolbar bulk operations
    selected = unselect.nil?
    find('table input.select-all').set(selected)
    find_all('tbody input[type="checkbox"]').all? do |checkbox|
      checkbox.checked? == selected
    end
  end
end

When "they select all items" do
  bulk_select(:all)
end

When "they deselect all items" do
  bulk_select(:none)
end

Then "the following bulk operations {are} available:" do |visible, operations|
  assert_same_elements find_all(bulk_action_selector).map(&:text), operations.raw.flatten
end

Then "the bulk operations {are} visible" do |visible|
  assert has_css?(selector_for('the bulk operations'), visible: visible)
end

Then "the bulk operation has failed for {string}" do |name|
  assert_match "There were some errors:\n#{name}", bulk_errors_container.text
end

When "select bulk action {string}" do |action|
  find(bulk_action_selector, text: action).click
end

def bulk_action_selector
  selector_for_bulk_operations = selector_for('the bulk operations')
  toggle_selector = "#{selector_for_bulk_operations} .pf-c-dropdown__toggle"
  if has_css?(toggle_selector, wait: 0)
    toggle = find(toggle_selector)
    toggle.click unless toggle[:class].split.include?('pf-m-expanded')
    action_selector = '.pf-c-dropdown__menu-item'
  else
    action_selector = '.operation'
  end

  "#{selector_for_bulk_operations} #{action_selector}"
end

def bulk_errors_container
  find('.bulk_operation.errors')
end

def bulk_select(amount)
  text = {
    :none => 'Select none',
    :page => 'Select page',
    :all => 'Select all'
  }[amount]

  within '.pf-m-bulk-select' do
    find('.pf-c-dropdown__toggle-button').click unless has_css?('.pf-c-dropdown.pf-m-expanded', wait: 0)
    find('.pf-c-dropdown__menu-item', text: text).click
  end
end
