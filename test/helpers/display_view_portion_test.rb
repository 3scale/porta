# frozen_string_literal: true

require 'test_helper'

class DisplayViewPortionTest < ActionView::TestCase
  include DisplayViewPortion
  helper DisplayViewPortion::Helper

  test 'returns false if nothing is set' do
    refute display_view_portion?(:service)
  end

  test 'returns true if set' do
    display_view_portion!(:service)
    assert display_view_portion?(:service)
  end
end
