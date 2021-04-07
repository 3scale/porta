# frozen_string_literal: true

class ApplicationPlanDecorator < ApplicationDecorator

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

  def index_table_data
    {
      id: id,
      name: name,
      editPath: h.edit_polymorphic_path([:admin, object]),
      applications: contracts_count,
      applicationsPath: h.admin_service_applications_path(service, search: { plan_id: id }),
      state: state,
      actions: index_table_actions
    }
  end

  def index_table_actions
    [
      published? ? nil : { title: 'Publish', path: h.publish_admin_plan_path(object), method: :post },
      published? ? { title: 'Hide', path: h.hide_admin_plan_path(object), method: :post } : nil,
      { title: 'Copy', path: h.admin_plan_copies_path(plan_id: id), method: :post },
      can_be_destroyed? ? { title: 'Delete', path: h.polymorphic_path([:admin, object]), method: :delete } : nil
    ].compact
  end
end
