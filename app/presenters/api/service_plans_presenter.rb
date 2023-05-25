# frozen_string_literal: true

class Api::ServicePlansPresenter < PlansBasePresenter
  def initialize(service:, user:, params: {})
    super(collection: service.provider.service_plans, user: user, params: params)
    @service = service
  end

  private

  attr_reader :service

  def current_plan
    service.default_service_plan&.as_json(root: false, only: %i[id name]) || nil
  end

  def masterize_path
    masterize_admin_service_service_plans_path(service)
  end

  def search_href
    admin_service_service_plans_path(service)
  end

  def create_button_props
    return unless can_create_plan?(ServicePlan)

    {
      href: new_polymorphic_path([:admin, @service, ServicePlan]),
      label: 'Create Service plan'
    }
  end
end
