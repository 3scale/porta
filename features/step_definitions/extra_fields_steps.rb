# frozen_string_literal: true

Given "{buyer} has extra fields:" do |buyer, table|
  buyer.extra_fields = table.hashes.first
  buyer.save!
end

Then "I {should} see error {string} for extra field {string}" do |visible, error, field|
  #TODO: the text selector is nasty
  assert_equal visible, has_xpath?("//*[contains(@class,'has-error')]/label[contains(text(),'#{field.first}')]")
end
