# frozen_string_literal: true

module CapybaraHelpers
  FLASH_SELECTOR = [
    '#flash-messages',
    '#flashWrapper span',
    '#flashWrapper p'
  ].join(', ').freeze

  def rack_test?
    %I[webkit selenium webkit_debug headless_chrome chrome headless_firefox firefox].exclude? Capybara.current_driver
  end

  def assert_flash(message)
    assert_match Regexp.new(message, true),
                 find(FLASH_SELECTOR).text
  end

  def assert_path_returns_error(path, status_code: 403)
    requests = inspect_requests do
      visit path
    end
    requests.first.status_code.should == status_code
  end
end

World(CapybaraHelpers)
