require 'test_helper'

class Liquid::Drops::PlanFeatureDropTest < ActiveSupport::TestCase

  include Liquid

  def setup
    @feature = FactoryBot.build_stubbed(:feature)
    @account_plan = FactoryBot.build_stubbed(:account_plan)
    @drop = Liquid::Drops::PlanFeature.new(@feature, @account_plan)
  end

  test 'inherit from Liquid::Drops::Feature' do
    assert_equal Drops::Feature, Drops::PlanFeature.ancestors[1]
  end

  test '#enabled?' do
    @account_plan.stubs includes_feature?: true
    assert @drop.enabled?

    @account_plan.stubs includes_feature?: false
    assert !@drop.enabled?
  end
end
