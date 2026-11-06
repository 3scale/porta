# frozen_string_literal: true

module PermittedPlanChangePermissions
  extend ActiveSupport::Concern

  included do
    helper_method :allowed_plan_change_permissions
  end

  private

  def finance_plan_permissions_available?
    current_account.settings.finance.allowed?
  end

  def allowed_plan_change_permissions
    if finance_plan_permissions_available?
      Logic::PlanChanges::PERMISSIONS
    else
      Logic::PlanChanges::PERMISSIONS[0..1]
    end
  end

  def filter_plan_change_permissions(permitted_params, *attributes)
    unavailable_values = (Logic::PlanChanges::PERMISSIONS - allowed_plan_change_permissions).map(&:to_s)
    attributes.each do |attribute|
      permitted_params.delete(attribute) if unavailable_values.include?(permitted_params[attribute])
    end
    permitted_params
  end
end
