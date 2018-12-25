require 'test_helper'

module Finance
  class LineItemTest < ActiveSupport::TestCase

    def setup
      @provider = FactoryBot.create(:simple_provider)
      @buyer = FactoryBot.create(:simple_buyer, :provider_account => @provider)

      @invoice = FactoryBot.create(:invoice,
                                :period => Month.new(Time.zone.local(1984, 1, 1)),
                                :provider_account => @provider,
                                :buyer_account => @buyer,
                                :friendly_id => '0000-00-00000001')

    end


    test 'rounding' do
      @invoice.line_items.create(cost: 0.04246)
      # number_to_currency(precision: 4) == 0.0425
      @invoice.line_items.create(cost: 0.04246)
      # number_to_currency(precision: 4) == 0.0425
      assert_equal( (0.0425 + 0.0425).round(2), @invoice.cost)
    end


    test 'other rounding' do
      item_a = @invoice.line_items.create(cost: 0.00009)
      # stored as 0.0001
      item_b = @invoice.line_items.create(cost: 0.00009)
      # stored as 0.0001
      assert_equal 0.0, @invoice.cost
      # (0.0001 + 0.0001).round(2) == 0.00
    end


    test 'rounds cost to 4 decimals' do
      litem = @invoice.line_items.create(cost: 0.0001)
      assert_equal 0.0001, litem.cost

      litem.cost = 0.0001
      assert_equal 0.0001, litem.cost

      litem.cost = 0.00014
      assert_equal 0.0001, litem.cost

      litem.cost = 0.00015
      assert_equal 0.0002, litem.cost

      litem.cost = 0.000151
      assert_equal 0.0002, litem.cost
    end

  end
end
