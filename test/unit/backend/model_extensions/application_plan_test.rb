# frozen_string_literal: true

require 'test_helper'

class Backend::ModelExtensions::ApplicationPlanTest < ActiveSupport::TestCase
  def setup
    @plan = FactoryBot.create(:application_plan)
  end

  attr_reader :plan

  test 'enqueues worker when plan name is updated' do
    BackendUpdateApplicationPlanJob.jobs.clear
    plan.update!(name: 'New Plan Name')
    assert_equal 1, BackendUpdateApplicationPlanJob.jobs.size
    assert_equal [plan.id], BackendUpdateApplicationPlanJob.jobs.first['args']
  end

  test 'does not enqueue worker when other attributes are updated' do
    BackendUpdateApplicationPlanJob.jobs.clear
    plan.update!(description: 'Updated description')
    assert_equal 0, BackendUpdateApplicationPlanJob.jobs.size
  end

  test 'does not enqueue worker when plan is created' do
    BackendUpdateApplicationPlanJob.jobs.clear
    FactoryBot.create(:application_plan)
    assert_equal 0, BackendUpdateApplicationPlanJob.jobs.size
  end
end
