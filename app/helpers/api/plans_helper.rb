# frozen_string_literal: true

module Api::PlansHelper
  delegate :account_plans, :default_account_plan, to: :current_account

  def change_application_plan_data(application)
    {
      'application-plans': application.available_application_plans.order_by(:name, :asc).to_json(root: false, only: %i[id name]),
      'path': change_plan_provider_admin_application_path
    }
  end
end
