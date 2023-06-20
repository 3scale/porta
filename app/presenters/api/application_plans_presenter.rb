# frozen_string_literal: true

class Api::ApplicationPlansPresenter < PlansBasePresenter
  def initialize(service:, user:, params: {})
    super(collection: service.application_plans, params: params, user: user)
    @service = service
  end

  private

  attr_reader :service

  def current_plan
    service.default_application_plan&.as_json(root: false, only: %i[id name]) || nil
  end

  def masterize_path
    masterize_admin_service_application_plans_path(service)
  end

  def search_href
    admin_service_application_plans_path(service)
  end

  def create_button_props
    return unless can_create_plan?(ApplicationPlan)

    {
      href: new_polymorphic_path([:admin, service, ApplicationPlan]),
      label: 'Create application plan'
    }
  end
end
