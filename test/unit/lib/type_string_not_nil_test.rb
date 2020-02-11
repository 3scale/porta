# frozen_string_literal: true

require 'test_helper'

class TypeStringNotNilTest < ActiveSupport::TestCase
  def test_type_cast_to_string_if_nil
    type = ActiveModel::Type::StringNotNil.new
    assert_equal '', type.cast(nil)
    assert_equal '', type.deserialize(nil)
  end
end
