# frozen_string_literal: true

Then "the {string} field {should} be readonly" do |id, readonly|
  expect(page).to have_field(id, readonly: readonly)
end

Then "the {string} checkbox {should} be disabled" do |id, disabled|
  expect(page).to have_field(id, disabled: disabled)
end

When "they select the first non-new-field option from {string}" do |select_id|
  select_element = find("##{select_id}")
  option = select_element.all('option').find { |o| o.value != '[new field]' }
  select_element.select(option.text)
end
