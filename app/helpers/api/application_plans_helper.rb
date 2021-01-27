# frozen_string_literal: true

module Api::ApplicationPlansHelper

  def application_plans_data
    @plans.not_custom
          .alphabetically
          .to_json(root: false, only: %i[id name])
  end

  def current_plan_id_data
    # -1 is the ID of the "select none" option in DefaultPlanSelector.jsx
    @service.default_application_plan.try!(:id) || -1
  end

end
