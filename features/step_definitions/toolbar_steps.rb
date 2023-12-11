# frozen_string_literal: true

When "(they )select toolbar action {string}" do |action|
  within selector_for('the toolbar') do
    if has_css?('.pf-c-button', text: action, wait: 0)
      find('.pf-c-button', text: action).click
    else
      find('.pf-c-overflow-menu .pf-c-dropdown__toggle').click unless has_css?('.pf-c-dropdown .pf-m-expanded', wait: 0)
      find('.pf-c-overflow-menu .pf-c-dropdown__menu-item', text: action).click
    end
  end
end

Then "they {can} find toolbar action {string}" do |can, action|
  within selector_for('the toolbar') do
    # Actions could be hidden inside a collapsed overflow menu
    find('.pf-m-overflow-menu .pf-c-dropdown:not(.pf-m-expanded)').click if
      has_css?('.pf-m-overflow-menu .pf-c-dropdown:not(.pf-m-expanded)', wait: 0)

    assert_equal can, has_css?('.pf-c-button', text: action, wait: 0)
  end
end
