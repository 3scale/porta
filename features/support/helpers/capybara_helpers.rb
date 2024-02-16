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
    request = requests.reject { |request| request.url&.include?('/assets/') }.first
    assert_equal status_code, request.status_code, "Expected: #{status_code} Actual: #{request.status_code} for #{request.url}"
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

  def find_inline_actions_of_row(row)
    if has_css?('td', text: row, wait: 0)
      dropdown = find('tr', text: row).find('.pf-c-table__action .pf-c-dropdown')
    elsif has_css?('.pf-c-data-list__cell', text: row, wait: 0)
      dropdown = find('.pf-c-data-list__item-row', text: row).find('.pf-c-data-list__item-action .pf-c-dropdown')
    else
      raise "No table or datalist row found with text: #{row}"
    end

    dropdown.find('.pf-c-dropdown__toggle').click if dropdown[:class].exclude?('pf-m-expanded')
    dropdown.all('.pf-c-dropdown__menu-item')
  end
end

World(CapybaraHelpers)
