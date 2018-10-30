class PlanDecorator < ApplicationDecorator

  def link_to_edit(**options)
    h.link_to(name, h.edit_admin_application_plan_path(self), options)
  end

  def link_to_applications(**options)
    live_applications = cinstances.live
    text = h.pluralize(live_applications.size, 'application')

    if h.can?(:show, Cinstance)
      h.link_to(text, plan_path, options)
    else
      text
    end
  end

  def plan_path
    service = context.fetch(:service) { object.service }
    h.admin_service_applications_path(service, search: { plan_id: id })
  end
end
