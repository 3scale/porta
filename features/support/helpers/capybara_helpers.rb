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
    # HACK: the error page requests assets that return 200 and checking the first one is not always
    # right. As an easy workaround, rule out requests with an url to assets.
    requests.reject { |request| request.url&.include?('/assets/') }.first.status_code.should == status_code
  end

  def assert_page_has_content(text)
    regex = Regexp.new(Regexp.escape(text), Regexp::IGNORECASE)
    if page.respond_to? :should
      page.should have_content(regex)
    else
      assert page.has_content?(regex)
    end
  end

  def assert_page_has_no_content(text)
    regex = Regexp.new(Regexp.escape(text), Regexp::IGNORECASE)
    refute_text :visible, regex
  end

  def assert_current_domain(domain)
    uri = URI.parse(current_url)
    assert_equal domain, uri.host
  end
end

World(CapybaraHelpers)
