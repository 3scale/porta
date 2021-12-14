# frozen_string_literal: true

require 'test_helper'

class Liquid::Drops::ServicePlanDropTest < ActiveSupport::TestCase
  setup do
    @plan = FactoryBot.create(:service_plan)
    @drop = Liquid::Drops::ServicePlan.new(@plan)
  end

  test 'should return id' do
    assert_equal @drop.id, @plan.id
  end
end
