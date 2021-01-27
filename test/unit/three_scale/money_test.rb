# frozen_string_literal: true

require 'test_helper'

module ThreeScale
  class MoneyTest < ActiveSupport::TestCase
    test 'initialize from cents' do
      amount = Money.cents(450, 'EUR').amount
      assert_equal 4.5, amount
      assert_instance_of BigDecimal, amount
    end
  end
end
