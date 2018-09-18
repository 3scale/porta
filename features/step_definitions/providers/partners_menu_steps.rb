Then /^I should see the partners menu$/ do
  response.should have_tag 'ul#subsubmenu'
end

#TODO: this step can be shorten using XPath
