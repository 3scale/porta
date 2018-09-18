require 'test_helper'

class Liquid::Drops::BillingAddressFieldTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @address = Account::BillingAddress::Address.new(name: 'Tim')
    @drop = Drops::BillingAddressField.new(@address, :name)
  end

  test 'it has value' do
    assert_equal @address.name, @drop.value
  end

  test 'it has label' do
    assert_equal 'Contact / Company Name', @drop.label
  end

  test 'it has name' do
    assert_equal 'name', @drop.name
  end
end
