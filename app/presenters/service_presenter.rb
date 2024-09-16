# frozen_string_literal: true

class ServicePresenter < SimpleDelegator
  include System::UrlHelpers.system_url_helpers

  def as_json(*)
    {service: stringify_nil_values(filtered_values)}.merge(error_messages)
  end

  def new_application_data
    {
      id: id,
      name: name,
      systemName: system_name,
      updatedAt: updated_at.to_s(:long),
      appPlans: plans.reorder(:name).stock.select(:id, :name).as_json(root: false),
      servicePlans: service_plans.reorder(:name).select(:id, :name).as_json(root: false),
      defaultServicePlan: default_service_plan.as_json(root: false, only: %i[id name]),
      defaultAppPlan: default_application_plan.as_json(root: false, only: %i[id name])
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
end
