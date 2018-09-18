module JavascriptHelper
  def stub_javascript_alert
    page.evaluate_script("
      window.alert = function (msg) {
        window.alert_message = msg;
        return true;
      }")
  end

  def last_javascript_alert
    page.evaluate_script("window.alert_message")
  end
end

World(JavascriptHelper)
