# frozen_string_literal: true

Given "{buyer} has extra fields:" do |buyer, table|
  buyer.extra_fields = table.hashes.first
  buyer.save!
end

Then "I should see error {string} for extra field {string}" do |error, field|
  assert has_css? ".has-error input[name*='[#{field.parameterize.underscore}]']"
  assert has_css?('.has-error .inline-errors', text: error)
end

Then "I should not see errors for extra field {string}" do |field|
  assert has_no_css? ".has-error input[name*='[#{field.parameterize.underscore}]']"
end
