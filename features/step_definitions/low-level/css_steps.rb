# frozen_string_literal: true

When "I request a css on db" do
  visit '/stylesheets/templates/test.css'
end

Then "I should see the css" do
  page.response_headers["Content-Type"].should be "text/css"
end
