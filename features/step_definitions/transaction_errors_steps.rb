Given /^(provider "[^"]*") has the following transaction errors:$/ do |provider, table|
  table.map_headers! { |header| header.downcase.to_sym }
  fake_transaction_errors(provider, table.hashes)
end

Given /^(provider "[^"]*") has no transaction errors$/ do |provider|
  fake_transaction_errors(provider, [])
end

Given /^the backend will delete transaction errors of (provider "[^"]*")$/ do |provider|
  expect_backend_delete_all_service_errors(provider.first_service!)
end

Then /^I should see the following transactions errors:$/ do |table|
  table.map_headers! { |header| header.downcase.to_sym }
  table.hashes.each do |hash|
    assert(all("table#transaction_errors tr.#{hash[:code]}").any? do |tr|
      tr.has_css?('td', :text => hash[:timestamp]) &&
      tr.has_css?('td', :text => hash[:message])
    end)
  end
end


def fake_transaction_errors(provider, errors)
  stub_backend_service_errors(provider.first_service!, errors)
end
