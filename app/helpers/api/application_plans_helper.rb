# frozen_string_literal: true

module Api::ApplicationPlansHelper

  def default_plan_data(service, plans)
    {
      'current-service': service.to_json(root: false, only: %i[id name]),
      'application-plans': application_plans_data(plans),
      'current-plan': default_application_plan_data(service)
    }
  end

  def application_plans_data(plans)
    plans.not_custom
         .alphabetically
         .to_json(root: false, only: %i[id name])
  end

  def default_application_plan_data(service)
    service.default_application_plan&.to_json(root: false, only: %i[id name]) || nil.to_json
  end

end
