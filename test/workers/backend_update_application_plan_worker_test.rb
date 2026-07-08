# frozen_string_literal: true

require 'test_helper'

class BackendUpdateApplicationPlanWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
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

    perform_enqueued_jobs(only: BackendUpdateApplicationPlanWorker) do
      BackendUpdateApplicationPlanWorker.perform_later(plan.id)
    end
  end

  test 'no n+1 queries' do
    ThreeScale::Core::Application.stubs(:save_batch)

    populate = ->(count) { FactoryBot.create_list(:simple_cinstance, count, plan: plan) }

    assert_perform_constant_number_of_queries(populate: populate) do
      BackendUpdateApplicationPlanWorker.new.perform(plan.id)
    end
  end

  test 'does nothing when plan does not exist' do
    ThreeScale::Core::Application.expects(:save_batch).never

    perform_enqueued_jobs(only: BackendUpdateApplicationPlanWorker) do
      BackendUpdateApplicationPlanWorker.perform_later(0)
    end
  end

  test 'does nothing when plan has no cinstances' do
    ThreeScale::Core::Application.expects(:save_batch).never

    perform_enqueued_jobs(only: BackendUpdateApplicationPlanWorker) do
      BackendUpdateApplicationPlanWorker.perform_later(plan.id)
    end
  end
end
