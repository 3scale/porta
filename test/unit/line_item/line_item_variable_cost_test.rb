require 'test_helper'

class LineItem::VariableCostTest < ActiveSupport::TestCase
  should belong_to :metric
end
