# frozen_string_literal: true

Then /^I fill the form with following:$/ do |table|
  table.hashes.each do |hash|
    hash.each_pair do |key, value|
      fill_in key, :with => value
    end
  end
end

When /^I click on the label "(.*?)"$/ do |label_text|
  page.find('label', :text => label_text).click
end

But "will not be able to edit its system name" do
  assert system_name_disabled?
end

Then "the submit button is {enabled}" do |enabled|
  assert_not_equal enabled, find('[type="submit"]').disabled?
end

Then "{string} shows error {string}" do |field, error|
  find_field(field).assert_sibling('.pf-c-form__helper-text.pf-m-error', text: error, wait: 0)
end

Then "{string} doesn't show any error" do |field|
  find_field(field).assert_no_sibling('.pf-c-form__helper-text.pf-m-error')
end

And "field {string} {is} disabled" do |field, disabled|
  assert_equal disabled, find_field(field).disabled?
end

Then "(I )should see field {string} {enabled}" do |field, enabled|
  assert has_field?(field, disabled: !enabled)
end

When "(I )(they )fill in {string} with {string}" do |field, value|
  ActiveSupport::Deprecation.warn "[cucumber] Detected a form not using PF4 css" unless page.has_css?('.pf-c-form__label', text: field)
  fill_in(field, with: value, visible: true)
end

When "(I )fill in the following:" do |fields|
  fields.rows_hash.each do |name, value|
    fill_in(name, with: value)
  end
end

When "the form is submitted with:" do |table|
  table.rows_hash.each { |name, value| fill_in(name, with: value) }
  find('.pf-c-form__actions button[type="submit"]', wait: 0).click
end

When "(I )select {string} from {string}" do |value, field|
  if page.has_css?('.pf-c-form__label', text: field)
    pf4_select(value, from: field)
  else
    # DEPRECATED: remove when all selects have been replaced for PF4
    ActiveSupport::Deprecation.warn "[cucumber] Detected a form not using PF4 css"
    find_field(field).find(:option, value).select_option
  end
end

When "(I )check {string}" do |field|
  check(field)
end

When "(I )uncheck {string}" do |field|
  uncheck(field)
end

# TODO: extend Node::Actions#select instead of using a custom method.
def pf4_select(value, from:)
  select = find_pf_select(from)
  within select do
    find('.pf-c-select__toggle').click unless select['class'].include?('pf-m-expanded')
    click_on(value)
  end
end

def pf4_select_first(from:)
  select = find_pf_select(from)
  within select do
    find('.pf-c-select__toggle').click unless select['class'].include?('pf-m-expanded')
    find('.pf-c-select__menu .pf-c-select__menu-item:not(.pf-m-disabled)').click
  end
end

def find_pf_select(label)
  find('.pf-c-form__group-label', text: label).sibling('.pf-c-form__group-control')
                                              .find('.pf-c-select')
end

# Overrides Node::Actions#fill_in
def fill_in
  if page.has_css?('.pf-c-form__label', text: field)
    input = find('.pf-c-form__label', text: field).sibling('input')
    input.set value
  else
    # DEPRECATED: remove when all forms implement PF4
    ActiveSupport::Deprecation.warn "[cucumber] Detected a form not using PF4 css"
    fill_in(field, :with => text, visible: true)
  end
end

def system_name_disabled?
  find('input[name$="[system_name]"]').disabled?
end
