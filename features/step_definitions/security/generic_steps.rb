# frozen_string_literal: true

Then "I should be denied the access" do
  assert_equal 403, page.status_code
end
