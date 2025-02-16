# frozen_string_literal: true

require 'capybara/minitest'

module CapybaraHelpers
  include Capybara::Minitest::Assertions

  FLASH_SELECTOR = [
    '#flash-messages',
    '#flashWrapper span',
    '#flashWrapper p'
  ].join(', ').freeze

  def javascript_test?
    Capybara.current_driver != Capybara.default_driver
  end

  def ensure_javascript
    raise 'Please mark this scenario with @javascript or another driver with JavaScript support' unless javascript_test?
  end

  def local_storage(key)
    Capybara.current_session.driver.browser.local_storage.[](key)
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
      overflow_menu = find('tr', text: row).find('.pf-c-table__action')

      if overflow_menu.has_css?('.pf-c-dropdown', wait: 0) # collapsed overflow menu
        dropdown = overflow_menu.find('.pf-c-dropdown')
      elsif overflow_menu.has_css?('.pf-c-overflow-menu', wait: 0) # desktop overflow menu
        desktop = overflow_menu.find('.pf-c-overflow-menu__content')
      end
    elsif has_css?('.pf-c-data-list__cell', text: row, wait: 0)
      dropdown = find('.pf-c-data-list__item-row', text: row).find('.pf-c-data-list__item-action .pf-c-dropdown')
    else
      raise "No table or datalist row found with text: #{row}"
    end

    if dropdown
      dropdown.find('.pf-c-dropdown__toggle').click if dropdown[:class].exclude?('pf-m-expanded')
      dropdown.all('.pf-c-dropdown__menu-item')
    elsif desktop
      desktop.all('.pf-c-overflow-menu__item')
    else
      raise "Can't find table actions"
    end
  end

  def select_attribute_filter(label)
    selector = find('[data-ouia-component-id="attribute-search"] .pf-c-toolbar__item:first-child')
    selector.click unless selector.has_css?('.pf-c-menu-toggle.pf-m-expanded', wait: 0)
    selector.find('.pf-c-menu')
            .find('.pf-c-menu__list-item', text: label)
            .click
  end

  def fill_attribute_filter(value)
    within '[data-ouia-component-id="attribute-search"] .pf-c-toolbar__item:last-child' do
      if has_css?('input', wait: 0)
        find('input').set(value)
        find('button.pf-m-control').click
      else
        find('button.pf-c-select__toggle, button.pf-c-select__toggle-button').click unless has_css?('.pf-c-select.pf-m-expanded', wait: 0)
        find('.pf-c-select__menu-item', text: value).click
      end
    end
  end
end

World(CapybaraHelpers)
