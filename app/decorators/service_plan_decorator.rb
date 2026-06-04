# frozen_string_literal: true

class ServicePlanDecorator < PlanBaseDecorator
  def link_to_edit
    h.link_to(name, h.edit_admin_service_plan_path(self))
  end

  def total_contracts
    I18n.t('api.services.cards.service_plans.contracts', count: contracts.size)
  end

  private

  def contracts_path
    h.admin_buyers_service_contracts_path(search: { plan_id: id })
  end
end
