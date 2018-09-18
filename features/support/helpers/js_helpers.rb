module JsHelpers
  def bypass_confirm_dialog
    # bypassing the confirm dialog
    # http://groups.google.com/group/ruby-capybara/browse_thread/thread/89760b6fcab7fd19
    # http://stackoverflow.com/questions/2458632/how-to-test-a-confirm-dialog-with-cucumber
    page.evaluate_script('window.confirm = function() { return true; }')
  end

  def ensure_javascript
    raise 'This step requires JS enabled' unless @javascript
  end
end
