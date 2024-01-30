# frozen_string_literal: true

Then "(I )fill the form with( following):" do |table|
  # TODO: deleteme and use "the form is filled with:"
  table.hashes.each do |hash|
    hash.each_pair do |key, value|
      fill_in key, :with => value
    end
  end
end

When /^I click on the label "(.*?)"$/ do |label_text|
  page.find('label', :text => label_text).click
end

Then "the submit button is {enabled}" do |enabled|
  assert_not_equal enabled, find('[type="submit"]').disabled?
end

INLINE_ERROR_SELECTORS = [
  '.pf-c-form__helper-text.pf-m-error',
  'p.inline-errors'
].join(', ')

Then "field {string} has inline error {string}" do |field, error|
  text = Regexp.new(Regexp.escape(error), Regexp::IGNORECASE)
  find_field(field)
    .assert_sibling(INLINE_ERROR_SELECTORS, text: text, wait: 0)
end

Then "field {string} has no inline error" do |field|
  find_field(field)
    .assert_no_sibling(INLINE_ERROR_SELECTORS, wait: 0)
end

Then /^there is (a|no)? (required )?(readonly )?field "(.*)"$/ do |presence, required, readonly, field|
  present = presence == 'a'
  assert_equal present, has_field?(field, readonly: readonly.present?)

  if present && required.present?
    assert find('label', text: field).has_css?('.required, .pf-c-form__label-required'),
           %("#{field}" exists, but it's not required)
  end
end
# Then "there {is} a field {string}" do |present, field|
# end

And "field {string} {is} disabled" do |field, disabled|
  assert has_field?(field, disabled: disabled)
end

And "select {string} {is} disabled" do |label, disabled|
  assert_equal disabled, find('.pf-c-form__group', text: label).has_css?('.pf-c-select .pf-m-disabled')
end

Then "(I )should see field {string} {enabled}" do |field, enabled|
  assert has_field?(field, disabled: !enabled)
end

And "field {string} {is} readonly" do |field, readonly|
  assert has_field?(field, readonly: readonly)
end

When "(I )(they )fill in {string} with {string}" do |field, value|
  fill_in(field, with: value, visible: true)
end

When "(I )fill in the following:" do |fields|
  fields.rows_hash.each do |name, value|
    fill_in(name, with: value)
  end
end

When "the form is filled with:" do |table|
  fill_form_with table
end

When "the form is submitted with:" do |table|
  submit_form_with table
end

When "the modal is submitted with:" do |table|
  within 'div.pf-c-modal-box form, #colorbox[role="dialog"] form' do
    submit_form_with table
  end
end

When "(I )(they )select {string} from {string}" do |value, field|
  if page.has_css?('.pf-c-form__label', text: field, wait: 0)
    pf4_select(value, from: field)
  else
    # DEPRECATED: remove when all selects have been replaced for PF4
    ActiveSupport::Deprecation.warn "[cucumber] Detected a form not using PF4 css"
    find_field(field).find(:option, value).select_option
  end
end

Then "(they )can't select {string} from {string}" do |option, label|
  select = find_pf_select(label)
  select.find('.pf-c-select__toggle').click unless select.has_css?('.pf-c-select__menu', wait: 0)
  assert_not select.has_css?('.pf-c-select__menu .pf-c-select__menu-item', text: option, wait: 0)
end

Then "{string} is the option selected in {string}" do |option, select|
  assert_equal option, find_field(select).value
end

When "(I )check {string}" do |field|
  check(field)
end

When "(I )uncheck {string}" do |field|
  uncheck(field)
end
