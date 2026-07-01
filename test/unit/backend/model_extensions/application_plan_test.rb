# frozen_string_literal: true

require 'test_helper'

class Backend::ModelExtensions::ApplicationPlanTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @plan = FactoryBot.create(:application_plan)
  end

  attr_reader :plan

  test 'enqueues worker when plan name is updated' do
    assert_enqueued_with(job: BackendUpdateApplicationPlanWorker, args: [plan.id]) do
      plan.update!(name: 'New Plan Name')
    end
  end

  test 'does not enqueue worker when other attributes are updated' do
    assert_no_enqueued_jobs(only: BackendUpdateApplicationPlanWorker) do
      plan.update!(description: 'Updated description')
    end
  end

  test 'does not enqueue worker when plan is created' do
    assert_no_enqueued_jobs(only: BackendUpdateApplicationPlanWorker) do
      FactoryBot.create(:application_plan)
    end
  end
end
