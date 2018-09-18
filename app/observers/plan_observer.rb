class PlanObserver < ActiveRecord::Observer

  observe :plan

  def plan_downgraded(plan, old_plan, contract)
    event = Plans::PlanDowngradedEvent.create(plan, old_plan, contract)
    Rails.application.config.event_store.publish_event(event)
  end
end
