# frozen_string_literal: true

Given "URL is inaccessible in browser: {string}" do |url|
  assert_match /:(?:\d+)\b/, url, "specify port in URL because of Capybara.always_include_port"

  available = true

  begin
    visit url
  rescue => e
    available = false
    puts "URL inaccessible in browser with: #{e.inspect}"
  end

  assert_not available, "URL should not be accessible but is."
end
