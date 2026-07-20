# frozen_string_literal: true

require 'test_helper'

class BackendUpdateApplicationPlanWorkerTest < ActiveSupport::TestCase
  include NPlusOneControl::MinitestHelper

  def setup
    @plan = FactoryBot.create(:application_plan)
  end

  attr_reader :plan

  test 'batch syncs plan name to backend for all cinstances' do
    cinstances = FactoryBot.create_list(:simple_cinstance, 2, plan: plan)

    expected_applications = cinstances.map do |cinstance|
      state = cinstance.state
      state = :active if cinstance.live?

      {
        service_id: plan.service.backend_id,
        id: cinstance.application_id,
        state: state,
        plan_id: plan.id,
        plan_name: plan.name,
        redirect_url: cinstance.redirect_url
      }
    end

    ThreeScale::Core::Application.expects(:save_batch).with(plan.service.backend_id, expected_applications)

    BackendUpdateApplicationPlanWorker.new.perform(plan.id)
  end

  test 'no n+1 queries' do
    ThreeScale::Core::Application.stubs(:save_batch)

    populate = ->(count) { FactoryBot.create_list(:simple_cinstance, count, plan: plan) }

    assert_perform_constant_number_of_queries(populate: populate) do
      BackendUpdateApplicationPlanWorker.new.perform(plan.id)
    end
  end

  test 'each_iteration logs error and does not raise when save_batch fails' do
    FactoryBot.create_list(:simple_cinstance, 2, plan: plan)
    batch = plan.cinstances.to_a

    ThreeScale::Core::Application.stubs(:save_batch).raises(StandardError, 'timeout')
    Rails.logger.expects(:error).with(regexp_matches(/Failed to sync application plan #{plan.name}.*timeout/))

    worker = BackendUpdateApplicationPlanWorker.new
    worker.each_iteration(batch, plan.id)
  end

  test 'does nothing when plan does not exist' do
    ThreeScale::Core::Application.expects(:save_batch).never

    BackendUpdateApplicationPlanWorker.new.perform(0)
  end

  test 'does nothing when plan has no cinstances' do
    ThreeScale::Core::Application.expects(:save_batch).never

    BackendUpdateApplicationPlanWorker.new.perform(plan.id)
  end
end
