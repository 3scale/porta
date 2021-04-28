# frozen_string_literal: true

class ServiceDecorator < ApplicationDecorator
  self.include_root_in_json = false

  def link_to_application_plans
    stock_application_plans = application_plans.stock
    text = h.pluralize(stock_application_plans.size, 'application plan')
    link = h.link_to(text, plans_path)
    link << " (#{h.h published_application_plans.size} published)"

    link.html_safe
  end

  def plans_path
    h.admin_service_application_plans_path(self)
  end

  def applications_path
    h.admin_service_applications_path(self, search: { state: 'live' })
  end

  def link_to_live_applications
    live_cinstances = cinstances.live
    text = h.pluralize(live_cinstances.size, 'live application')

    if h.can?(:show, Cinstance)
      h.link_to text, applications_path
    else
      text
    end
  end

  def published_application_plans
    ApplicationPlanDecorator.decorate_collection(application_plans.stock.published, context: { service: self })
  end

  def api_selector_api_link
    if h.can?(:manage, :plans)
      h.admin_service_path(object)
    elsif h.can?(:manage, :monitoring)
      h.admin_service_stats_usage_path(object)
    elsif h.can?(:manage, :partners)
      h.admin_service_applications_path(object)
    end
  end

  def used_by_backend_table_data
    {
      id: id,
      name: name,
      systemName: system_name,
      path: link # Verify that api_selector_api_link is the right call
    }
  end

  alias link api_selector_api_link

  def new_application_data
    {
      id: id.to_s,
      name: name,
      systemName: system_name,
      updatedAt: updated_at,
      appPlans: plans.stock.select(:id, :name).as_json(root: false),
      servicePlans: service_plans.select(:id, :name).as_json(root: false),
      defaultServicePlan: default_service_plan.as_json(root: false, only: %i[id name])
    }
  end

  private

  def backend_api?
    false
  end

  def links
    [
      { name: 'Edit', path: h.edit_admin_service_path(object) },
      { name: 'Overview', path: h.admin_service_path(object) },
      { name: 'Analytics', path: h.admin_service_stats_usage_path(object) },
      { name: 'Applications', path: h.admin_service_applications_path(object) },
      { name: 'ActiveDocs', path: h.admin_service_api_docs_path(object) },
      { name: 'Integration', path: h.admin_service_integration_path(object) },
    ]
  end

  def apps_count
    cinstances.size
  end

  def backends_count
    backend_api_configs.size
  end

  def unread_alerts_count
    account.buyer_alerts
           .by_service(object)
           .unread
           .size
  end
end
