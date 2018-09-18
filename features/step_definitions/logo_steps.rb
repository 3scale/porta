Then /^(provider "[^"]*") should have logo "([^"]*)"$/ do |provider, logo|
  assert_equal logo, provider.profile.logo_file_name
end

Then /^(provider "[^"]*") should have no logo$/ do |provider|
  assert_nil provider.profile.logo_file_name
end

Given /^(provider "[^"]*") has logo "([^"]*)"$/ do |provider, path|
  provider.profile.update_attribute(:logo, Rack::Test::UploadedFile.new(path, 'image/jpeg', true))
end
