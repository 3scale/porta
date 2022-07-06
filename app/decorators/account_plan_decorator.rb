# frozen_string_literal: true

class AccountPlanDecorator < PlanBaseDecorator
  private

  def contracts_path
    h.admin_buyers_accounts_path(search: { plan_id: id })
  end
end
