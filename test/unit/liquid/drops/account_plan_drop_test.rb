require 'test_helper'

class Liquid::Drops::AccountPlanDropTest < ActiveSupport::TestCase

  setup do
    @plan = FactoryGirl.create(:account_plan)
    @drop = Liquid::Drops::AccountPlan.new(@plan)
  end

  test 'id' do
    assert_equal @drop.id, @plan.id
  end

  test 'features' do
    feature = FactoryGirl.build_stubbed(:feature)
    @plan.stub_chain(:issuer, :features, :visible).returns([feature])
    @plan.stubs includes_feature?: true

    assert_kind_of Liquid::Drops::PlanFeature, @drop.features[0]
  end

  test "enabled?" do
    feature = FactoryGirl.build_stubbed(:feature)
    @plan.stub_chain(:issuer, :features, :visible).returns([feature])
    @plan.stubs includes_feature?: true
    assert @drop.features[0].enabled?

    @plan.stubs includes_feature?: false
    assert !@drop.features[0].enabled?
  end

  test "setup_fee" do
    @plan.setup_fee = 0
    assert_equal 0, @drop.setup_fee

    @plan.stubs(:currency).returns('EUR')
    @plan.setup_fee = 42.24
    assert_equal 'EUR&nbsp;42.24', @drop.setup_fee
  end
end
