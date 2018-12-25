require 'test_helper'

class Liquid::Drops::LineItemDropTest < ActiveSupport::TestCase

  include Liquid

  def setup
    @line_item = FactoryBot.build(:line_item)
    @drop = Drops::LineItem.new(@line_item)
  end

  should "return name" do
    @line_item.name = 'foo'
    assert_equal(@line_item.name, @drop.name)
  end

  should "return description" do
    @line_item.description = 'description foo'
    assert_equal(@line_item.description, @drop.description)
  end

  should "return quantity" do
    @line_item.quantity = 5
    assert_equal(@line_item.quantity, @drop.quantity)
  end

  should "return cost" do
    @line_item.cost = ThreeScale::Money.new(245, 'EUR')
    assert_equal('245.00', @drop.cost)
  end
end
