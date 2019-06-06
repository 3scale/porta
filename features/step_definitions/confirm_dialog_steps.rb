Then /^(.+) and I confirm dialog box(?: "(.*)")?$/ do |original, text|
  if [:webkit, :selenium, :webkit_debug, :headless_chrome, :chrome, :headless_firefox, :firefox].include? Capybara.current_driver
    accept_confirm(text) do
      step original
    end
  else # :rack_test but should not work if it relies on some JS
    step original
  end
end
