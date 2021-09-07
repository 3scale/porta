# frozen_string_literal: true

module Api::PlansHelper

  def change_application_plan_data(application)
    {
      'application-plans': application_plans_data(application.available_application_plans),
      'path': change_plan_provider_admin_application_path
    }
  end

  def default_application_plan_data(service, plans)
    {
      'service': service.to_json(root: false, only: %i[id name]),
      'application-plans': application_plans_data(plans),
      'current-plan': current_application_plan_data(service),
      'path': masterize_admin_service_application_plans_path(':id')
    }
  end

  def application_plans_data(plans)
    plans.order(name: :asc)
         .to_json(root: false, only: %i[id name])
  end

  def current_application_plan_data(service)
    service.default_application_plan&.to_json(root: false, only: %i[id name]) || nil.to_json
  end

  def application_plans_table_data(service_id:, page_plans:, plans_size:)
    {
      plans: application_plans_index_data(page_plans).to_json,
      count: plans_size,
      'search-href': admin_service_application_plans_path(service_id)
    }
  end

  def application_plans_index_data(plans)
    plans.decorate
         .map(&:index_table_data)
  end

end
