# frozen_string_literal: true

require 'test_helper'

class ServicePlanDecoratorTest < Draper::TestCase
  def setup
    @plan = FactoryBot.create(:service_plan, issuer: FactoryBot.create(:service))
    @decorator = @plan.decorate
  end

  attr_reader :decorator

  test '#index_table_data' do
    data = decorator.index_table_data

    assert data.assert_valid_keys(:id, :name, :editPath, :contracts, :contractsPath, :state, :actions)
  end
end
