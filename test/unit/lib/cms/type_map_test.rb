# frozen_string_literal: true

require 'test_helper'

class CMS::TypeMapTest < ActiveSupport::TestCase
  class CMS::ClassTest < CMS::TypeMapTest
    test 'returns an existing class from string' do
      cms_type = 'partial'

      result = CMS::TypeMap.cms_class(cms_type)

      assert_equal CMS::Partial, result
    end

    test 'returns an existing class from symbol' do
      cms_type = :builtin_page

      result = CMS::TypeMap.cms_class(cms_type)

      assert_equal CMS::Builtin::Page, result
    end

    test "doesn't return an existing class from nil" do
      cms_type = nil

      result = CMS::TypeMap.cms_class(cms_type)

      assert_nil result
    end

    test "doesn't return an existing class from an input not responding to :to_sym" do
      cms_type = 1

      result = CMS::TypeMap.cms_class(cms_type)

      assert_nil result
    end
  end

  class CMS::TypeTest < CMS::TypeMapTest
    test 'returns an existing type from class' do
      cms_class = CMS::Partial

      result = CMS::TypeMap.cms_type(cms_class)

      assert_equal :partial, result
    end

    test "doesn't return an existing type from nil" do
      cms_class = nil

      result = CMS::TypeMap.cms_type(cms_class)

      assert_nil result
    end

    test "doesn't return an existing type from an input not responding to :to_sym" do
      cms_class = 1

      result = CMS::TypeMap.cms_type(cms_class)

      assert_nil result
    end
  end
end
