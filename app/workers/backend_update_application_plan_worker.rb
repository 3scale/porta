# frozen_string_literal: true

class BackendUpdateApplicationPlanWorker < ApplicationJob
  queue_as :backend_sync

  # :reek:UtilityFunction
  def perform(plan_id)
    plan = ApplicationPlan.find_by(id: plan_id)
    return unless plan

    plan.update_backend_plan
  end
end
