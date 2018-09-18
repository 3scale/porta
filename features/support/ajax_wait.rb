module AjaxWait
  class WaitForAjax < StandardError; end

  def wait_for_ajax
    errors = page.driver.invalid_element_errors + [
        Capybara::ElementNotFound,
        # ::Selenium::WebDriver::Error::StaleElementReferenceError,
        WaitForAjax
    ]
    page.document.synchronize(Capybara.default_max_wait_time ** 3, errors: errors) do
      return true if page.evaluate_script('typeof(jQuery) === "undefined"') # we dont have jQuery, so dont need to wait

      active = page.evaluate_script('jQuery.active')
      animated = page.evaluate_script('jQuery(":animated").length')
      spinners = page.all('i.fa-spinner.fa-spin', visible: true).size
      loaded = page.evaluate_script('document.readyState == "complete"')

      raise WaitForAjax unless active == 0 && animated == 0 && spinners == 0 && loaded
    end
  rescue Capybara::NotSupportedByDriverError
    # nothing
  end
end

World(AjaxWait)
