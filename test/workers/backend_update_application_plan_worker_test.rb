# frozen_string_literal: true

require 'test_helper'

class BackendUpdateApplicationPlanWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include NPlusOneControl::MinitestHelper

  def setup
    @plan = FactoryBot.create(:application_plan)
  end

  attr_reader :plan

  test 'syncs plan name to backend for each cinstance' do
    cinstances = FactoryBot.create_list(:simple_cinstance, 2, plan: plan)

    cinstances.each do |cinstance|
      ThreeScale::Core::Application.expects(:save)
        .with(has_entries(service_id: plan.service.backend_id,
                          id: cinstance.application_id,
                          plan_id: plan.id,
                          plan_name: plan.name))
    end

    perform_enqueued_jobs(only: BackendUpdateApplicationPlanWorker) do
      BackendUpdateApplicationPlanWorker.perform_later(plan.id)
    end
  end

  test 'no n+1 queries' do
    ThreeScale::Core::Application.stubs(:save)

    populate = ->(n) { FactoryBot.create_list(:simple_cinstance, n, plan: plan) }

    assert_perform_constant_number_of_queries(populate: populate) do
      BackendUpdateApplicationPlanWorker.new.perform(plan.id)
    end
  end

  test 'does nothing when plan does not exist' do
    ThreeScale::Core::Application.expects(:save).never

    perform_enqueued_jobs(only: BackendUpdateApplicationPlanWorker) do
      BackendUpdateApplicationPlanWorker.perform_later(0)
    end
  end

  test 'does nothing when plan has no cinstances' do
    ThreeScale::Core::Application.expects(:save).never

    perform_enqueued_jobs(only: BackendUpdateApplicationPlanWorker) do
      BackendUpdateApplicationPlanWorker.perform_later(plan.id)
    end
  end
end
