# frozen_string_literal: true

Given "{provider} has no site access code" do |provider|
  provider.update!(site_access_code: nil)
end

Given "{provider} has site access code {string}" do |provider, code|
  provider.update!(site_access_code: code)
end

When "I enter {string} as access code" do |code|
  fill_in('Access code', with: code)
  click_button 'Enter'
end

Then "I should not be in the access code page" do
  assert has_no_content?('Access code')
end
