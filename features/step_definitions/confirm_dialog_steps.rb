When 'I will confirm dialog box' do
  warn Cucumber::Term::ANSIColor.red('DEPRECATION WARNING: "I will confirm dialog box" step is deprecated. Please use "(step) and I confirm dialog box"')
  bypass_confirm_dialog
end

Then /^(.+) and I confirm dialog box$/ do |original|
  if [:webkit, :selenium, :webkit_debug, :headless_chrome, :chrome].include? Capybara.current_driver
    accept_confirm do
      step original
    end
  else # :rack_test but should not work if it relies on some JS
    step original
  end
end
