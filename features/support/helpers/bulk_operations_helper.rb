# frozen_string_literal: true

module BulkOperationsHelper
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
end

World(BulkOperationsHelper)
