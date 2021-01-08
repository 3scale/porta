# frozen_string_literal: true

When "I switch to non-secure version of the same page" do
  insecure_url = current_url.gsub(/^https/, 'http')
  visit insecure_url
end

Given "domain {string} supports SSL" do |domain|
  Domain.stubs(:supports_ssl?).with(domain).returns(true)
end
