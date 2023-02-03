# frozen_string_literal: true

class Api::ApplicationPlansPresenter < PlansBasePresenter
  def initialize(service:, params: {})
    super(collection: service.application_plans, params: params)
    @service = service
  end

  private

  attr_reader :service

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
