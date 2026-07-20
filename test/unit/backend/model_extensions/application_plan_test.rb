# frozen_string_literal: true

require 'test_helper'

class Backend::ModelExtensions::ApplicationPlanTest < ActiveSupport::TestCase
  def setup
    @plan = FactoryBot.create(:application_plan)
  end

  attr_reader :plan

  test 'enqueues worker when plan name is updated' do
    BackendUpdateApplicationPlanWorker.jobs.clear
    plan.update!(name: 'New Plan Name')
    assert_equal 1, BackendUpdateApplicationPlanWorker.jobs.size
    assert_equal [plan.id], BackendUpdateApplicationPlanWorker.jobs.first['args']
  end

  test 'does not enqueue worker when other attributes are updated' do
    BackendUpdateApplicationPlanWorker.jobs.clear
    plan.update!(description: 'Updated description')
    assert_equal 0, BackendUpdateApplicationPlanWorker.jobs.size
  end

  test 'does not enqueue worker when plan is created' do
    BackendUpdateApplicationPlanWorker.jobs.clear
    FactoryBot.create(:application_plan)
    assert_equal 0, BackendUpdateApplicationPlanWorker.jobs.size
  end
end
