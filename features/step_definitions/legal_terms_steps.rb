Given /^(provider "[^\"]*") has no legal terms$/ do |provider|
  provider.builtin_legal_terms.delete_all
end

Given /^(provider "[^"]*") has service subscription legal terms:$/ do |provider, text|
  provider.builtin_legal_terms.create!(system_name: CMS::Builtin::LegalTerm::SUBSCRIPTION_SYSTEM_NAME,
                                      published: text)
end


Then /^(provider "[^"]*") should have "([^"]*)" creation binded to (legal terms "[^"]*")$/ do |provider, scope, legal_terms|
  provider.legal_term_for(scope).should == legal_terms
end


Then /^I should see my legal term$/ do
  assert has_content?("new multitenant legal terms")
end

Then /^I should see my legal term changed$/ do
  assert has_content?("updated multitenant legal terms")
end

When /^I select "([^"]*)" legal term "([^"]*)"$/ do |term, scope|
  select = find :xpath, "//fieldset[@name='#{scope}']//select"
  value = select.find(:xpath, XPath::HTML.option(term))

  case select.native
  when Nokogiri::XML::Element, String
    value.select_option
  else
    value.click
  end
end
