# frozen_string_literal: true

When /^item "(.+?)" is (un)?selected$/ do |name, unselect|
  find('tbody td', text: name)
    .find(:xpath, '..')
    .find('.select input[type="checkbox"]')
    .set(unselect.nil?)
end

When "they select all items in the current page" do
  bulk_select :page
end

When /^they (un)?select all items in the table$/ do |unselect|
  if has_css?('.pf-c-toolbar .pf-m-bulk-select', wait: 0)
    bulk_select(unselect ? :none : :all)
  else
    # DEPRECATED: remove when all tables use PF4 toolbar bulk operations
    selected = unselect.nil?
    find('table input.select-all').set(selected)
    find_all('tbody input[type="checkbox"]').all? do |checkbox|
      checkbox.checked? == selected
    end
  end
end

Then "the following bulk operations {are} available:" do |visible, operations|
  assert_same_elements find_all(bulk_action_selector).map(&:text), operations.raw.flatten
end

Then "the bulk operation has failed for {string}" do |name|
  find('.bulk_operation.errors').assert_text("There were some errors:\n#{name}")
end

When "(they )select bulk action {string}" do |action|
  find(bulk_action_selector, text: action).click
end
