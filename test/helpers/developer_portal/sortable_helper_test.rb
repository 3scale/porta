# frozen_string_literal: true

require 'test_helper'

module DeveloperPortal
  class SortableHelperTest < ActionView::TestCase
    test 'title_with_order_indicator with asc direction' do
      result = title_with_order_indicator('Name', 'asc')
      assert_equal 'Name ▲', result
      assert result.html_safe?
    end

    test 'title_with_order_indicator with desc direction' do
      result = title_with_order_indicator('Name', 'desc')
      assert_equal 'Name ▼', result
      assert result.html_safe?
    end

    test 'title_with_order_indicator with up direction' do
      result = title_with_order_indicator('Name', 'up')
      assert_equal 'Name ▲', result
      assert result.html_safe?
    end

    test 'title_with_order_indicator with down direction' do
      result = title_with_order_indicator('Name', 'down')
      assert_equal 'Name ▼', result
      assert result.html_safe?
    end

    test 'title_with_order_indicator with nil direction' do
      result = title_with_order_indicator('Name', nil)
      assert_equal 'Name', result
      assert result.html_safe?
    end

    test 'title_with_order_indicator with invalid direction' do
      result = title_with_order_indicator('Name', 'invalid')
      assert_equal 'Name', result
      assert result.html_safe?
    end

    test 'title_with_order_indicator with symbol direction' do
      result = title_with_order_indicator('Name', :asc)
      assert_equal 'Name ▲', result
      assert result.html_safe?
    end

    test 'title_with_order_indicator HTML escapes title' do
      result = title_with_order_indicator('<script>alert("XSS")</script>', 'asc')
      assert_equal '&lt;script&gt;alert(&quot;XSS&quot;)&lt;/script&gt; ▲', result
      assert result.html_safe?
    end

    test 'title_with_order_indicator with special characters in title' do
      result = title_with_order_indicator('User & Admin', 'desc')
      assert_equal 'User &amp; Admin ▼', result
      assert result.html_safe?
    end

    test 'title_with_order_indicator preserves title case' do
      result = title_with_order_indicator('UPPERCASE Name', 'asc')
      assert_equal 'UPPERCASE Name ▲', result
      assert result.html_safe?
    end
  end
end
