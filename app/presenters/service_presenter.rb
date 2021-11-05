# frozen_string_literal: true

class ServicePresenter < SimpleDelegator
  include System::UrlHelpers.system_url_helpers

  def as_json(*)
    {service: stringify_nil_values(filtered_values)}.merge(error_messages)
  end

  def index_data
    {
      id: id,
      name: name,
      systemName: system_name,
      updatedAt: updated_at.to_s(:long),
      links: links,
      appsCount: cinstances.size,
      backendsCount: backend_api_configs.size,
      unreadAlertsCount: decorate.unread_alerts_count
    }
  end

  def new_application_data
    {
      id: id,
      name: name,
      systemName: system_name,
      updatedAt: updated_at.to_s(:long),
      appPlans: plans.stock.select(:id, :name).as_json(root: false),
      servicePlans: service_plans.select(:id, :name).as_json(root: false),
      defaultServicePlan: default_service_plan.as_json(root: false, only: %i[id name]),
      defaultAppPlan: default_application_plan.as_json(root: false, only: %i[id name])
    }
  end

  def dashboard_widget_data
    {
      id: id,
      name: name,
      updated_at: updated_at.to_s(:long),
      link: decorate.link,
      links: links
    }
  end

  private

  def filtered_values
    __getobj__.as_json(root: false, only: %i[name system_name description])
  end

  def error_messages
    {errors: __getobj__.errors.messages.presence || {} }
  end

  def stringify_nil_values(hash)
    hash.transform_values(&:to_s)
  end

  def links
    [
      { name: 'Edit', path: edit_admin_service_path(self) },
      { name: 'Overview', path: admin_service_path(self) },
      { name: 'Analytics', path: admin_service_stats_usage_path(self) },
      { name: 'Applications', path: admin_service_applications_path(self) },
      { name: 'ActiveDocs', path: admin_service_api_docs_path(self) },
      { name: 'Integration', path: admin_service_integration_path(self) },
    ]
  end
end
