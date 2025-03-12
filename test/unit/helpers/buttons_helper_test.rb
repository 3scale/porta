# frozen_string_literal: true

require 'test_helper'

class ButtonsHelperTest < ActionView::TestCase
  include ApplicationHelper

  test 'fancy_button_to remote functionality' do
    button = fancy_button_to('Add new key', '/', remote: true)
    assert_equal 'true', Nokogiri::HTML4.parse(button).at_css('form').attribute('data-remote').value

    button = fancy_button_to('Add new key', '/', remote: false)
    assert_nil Nokogiri::HTML4.parse(button).at_css('form').attribute('data-remote')

    button = fancy_button_to('Add new key', '/')
    assert_nil Nokogiri::HTML4.parse(button).at_css('form').attribute('data-remote')
  end
end
