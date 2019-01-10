require 'test_helper'

class Liquid::Drops::FeatureDropTest < ActiveSupport::TestCase
  def setup
    @feature = FactoryBot.build_stubbed(:feature)
    @drop = Liquid::Drops::Feature.new(@feature)
  end

  test '#system_name' do
    @feature.system_name = 'foo_bar_foo'
    assert_equal @feature.system_name, @drop.system_name
  end
end
