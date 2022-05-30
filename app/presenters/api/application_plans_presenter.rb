# frozen_string_literal: true

class Api::ApplicationPlansPresenter < PlansBasePresenter
  def initialize(service:, collection:, params: {})
    super(service: service, collection: collection, params: params)
  end

  private

  def current_plan
    service.default_application_plan&.to_json(root: false, only: %i[id name]) || nil.to_json
  end

  def masterize_path
    masterize_admin_service_application_plans_path(service)
  end

  def search_href
    admin_service_application_plans_path(service)
  end
end
