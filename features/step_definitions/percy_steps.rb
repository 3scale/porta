Then(/^I take a screenshot of "([^"]*)"$/) do |name|
  steps %(
    When I go to #{name}
    Then I take a screenshot of the current page and name it "#{name}"
  )
end

Then(/^I take a screenshot of the current page and name it "([^"]*)"$/) do |name|
  Percy::Capybara.snapshot(page, name: name) if $percy # initialized in features/support/percy.rb
  path = Capybara.save_path.join('percy', "#{name.parameterize}.png")
  save_screenshot(path.to_s)
  print "Saved Percy screenshot to #{path}\n"
end
