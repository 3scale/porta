# frozen_string_literal: true

require 'test_helper'

class TypeStringNotNilTest < ActiveSupport::TestCase
  def test_type_cast_to_string_if_nil
    type = ActiveRecord::Type::StringNotNil.new
    assert_equal '', type.type_cast_from_database(nil)
    assert_equal '', type.type_cast_from_user(nil)
    assert_equal '', type.type_cast(nil)
  end
end
