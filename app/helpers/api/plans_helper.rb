# frozen_string_literal: true

module Api::PlansHelper

  def default_application_plan_data(service, plans)
    {
      'service': service.to_json(root: false, only: %i[id name]),
      'application-plans': application_plans_data(plans),
      'current-plan': current_application_plan_data(service),
      'path': masterize_admin_service_application_plans_path(':id')
    }
  end

  def application_plans_data(plans)
    plans.not_custom
         .alphabetically
         .to_json(root: false, only: %i[id name])
  end

  def current_application_plan_data(service)
    service.default_application_plan&.to_json(root: false, only: %i[id name]) || nil.to_json
  end

end
