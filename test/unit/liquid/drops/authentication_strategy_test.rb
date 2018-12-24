require 'test_helper'

class Liquid::Drops::AuthenticationStrategyTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @buyer = FactoryBot.create(:buyer_account)
    FieldsDefinition.create(account: @buyer.provider_account, target: 'Account',
                            name: 'country', label: 'Country')
    @buyer.reload
  end

  test 'country#choices' do
    drop = Drops::CountryField.new(@buyer, :country)
    country = drop.choices.first
    assert country.id.is_a?(Fixnum)
    assert country.label.is_a?(String)
  end

end
