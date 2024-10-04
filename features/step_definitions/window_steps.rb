# frozen_string_literal: true

And "(they )set the screen width to {string} pixels" do |width|
  height = page.driver.browser.manage.window.size.height
  page.driver.browser.manage.window.resize_to(width.to_i, height)
end
