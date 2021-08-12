# frozen_string_literal: true

Then "I {should} see the link to the dashboard" do |visible|
  assert_equal visible, has_css?('a', text: 'Dashboard')
end

Then "I {should} see the link to the admin area" do |visible|
  assert_equal visible, has_css?('a', text: 'Admin')
end
