# frozen_string_literal: true

When /^item "(.+?)" is (un)?selected$/ do |name, unselect|
  find(:xpath, "//td[text()='#{name}']/..")
    .find('.select input[type="checkbox"]')
    .set(unselect.nil?)
end

When /^they (un)?select all items in the table$/ do |unselect|
  selected = unselect.nil?
  find('table input.select-all').set(selected)
  find_all('tbody input[type="checkbox"]').all? do |checkbox|
    checkbox.checked? == selected
  end
end

Then "the following bulk operations {are} available:" do |visible, operations|
  within bulk_operations_selector do
    assert_same_elements find_all('.operation').map(&:text), operations.raw.flatten
  end
end

Then "the bulk operations {are} visible" do |visible|
  assert has_css?(bulk_operations_selector, visible: visible)
end

def bulk_operations_selector
  '#bulk-operations'
end
