require 'test_helper'

class Liquid::Drops::FieldTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @account = FactoryBot.create(:buyer_account)

    # With the update to rails 3.2.15
    # we have to reload @account, to access properly to #define_fields,
    # looks like only happend with the factory.
    @account.reload

    @field = @account.defined_fields.first
    @value = @account.field_value(@field.name)
    @drop = Drops::Field.new(@account, @field.name)
  end

  test 'it behaves like string' do
    assert_equal @value, @drop.to_str
  end

  test 'it has value' do
    assert_equal @value, @drop.value
  end

  test 'it has label' do
    assert_equal @field.label, @drop.label
  end

  test 'it has name' do
    assert_equal @field.name.to_s, @drop.name
  end

  test 'it has ==' do
    assert_equal @drop, @drop.to_str
    assert_equal @drop.to_str, @drop
  end

  test 'country#choices' do
    FieldsDefinition.create(account: @account.provider_account, target: 'Account',
                            name: 'country', label: 'Country')
    @account.reload.defined_fields.find { |f| f.name == 'country' }.inspect
    drop = Drops::CountryField.new(@account, :country)

    assert_equal 'Country', drop.label
    assert_equal 'country', drop.name

    puts drop.choices.inspect
  end

end
