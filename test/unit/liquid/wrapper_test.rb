require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Liquid::WrapperTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @service = FactoryBot.create(:service)
  end

  test 'wrap_service with current account' do
    @buyer = FactoryBot.create(:buyer_account)
    wrapper = Liquid::Wrapper.new(@buyer)

    drop = wrapper.wrap_service(@service)

    assert_not_nil drop
    assert drop.is_a? Drops::Service
  end

  test 'wrap_service without current account' do
    wrapper = Liquid::Wrapper.new

    drop = wrapper.wrap_service(@service)

    assert_not_nil drop
    assert drop.is_a? Drops::Service
  end

end

