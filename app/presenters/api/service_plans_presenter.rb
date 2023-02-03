# frozen_string_literal: true

class Api::ServicePlansPresenter < PlansBasePresenter
  def initialize(service:, params: {})
    super(collection: service.provider.service_plans, params: params)
    @service = service
  end

  private

  attr_reader :service

  def current_plan
    service.default_service_plan&.to_json(root: false, only: %i[id name]) || nil.to_json
  end

  def masterize_path
    masterize_admin_service_service_plans_path(service)
  end

  def search_href
    admin_service_service_plans_path(service)
  end
end
