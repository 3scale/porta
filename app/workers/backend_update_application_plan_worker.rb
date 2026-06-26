# frozen_string_literal: true

class BackendUpdateApplicationPlanWorker < ApplicationJob
  queue_as :backend_sync

  def perform(plan_id)
    plan = ApplicationPlan.find_by(id: plan_id)
    return unless plan

    plan.cinstances.includes(:service, :plan).find_each(&:update_backend_application)
  end
end
