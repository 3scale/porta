# frozen_string_literal: true

class ServicePlanDecorator < PlanBaseDecorator
  private

  def contracts_path
    h.admin_buyers_service_contracts_path(search: { plan_id: id })
  end
end
