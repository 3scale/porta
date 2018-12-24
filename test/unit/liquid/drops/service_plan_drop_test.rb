require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Liquid::Drops::ServicePlanDropTest < ActiveSupport::TestCase
  context 'ServicePlanDrop' do
    setup do
      @plan = FactoryBot.create(:service_plan)
      @drop = Liquid::Drops::ServicePlan.new(@plan)
    end

    should 'return id' do
      assert_equal @drop.id, @plan.id
    end
  end
end
