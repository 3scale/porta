# frozen_string_literal: true

class Api::MetricVisibilitiesController < FrontendController
  before_action :authorize_section

  before_action :find_plan
  before_action :find_service
  before_action :find_metric

  def toggle_visible
    @metric.toggle_visible_for_plan(@plan)

    respond_to do |format|
      format.html { redirect_to edit_admin_application_plan_path(@plan) }
      format.js
    end
  end

  def toggle_limits_only_text
    @metric.toggle_limits_only_text_for_plan(@plan)

    respond_to do |format|
      format.html { redirect_to edit_admin_application_plan_path(@plan) }
      format.js
    end
  end

  def toggle_enabled
    @metric.toggle_enabled_for_plan(@plan)

    respond_to do |format|
      format.html do
        errors = @metric.errors.presence
        flash[:error] = errors.full_messages.to_sentence if errors
        redirect_to edit_admin_application_plan_path(@plan)
      end

      format.js do
        @usage_limits = @plan.usage_limits.where(metric_id: @metric.id)
      end
    end
  end

  private

  def find_plan
    @plan = current_account.application_plans.find(params[:application_plan_id])
  end

  def find_service
    @service = current_user.accessible_services.find(@plan.issuer_id)
  end

  def find_metric
    @metric = @service.all_metrics.find(params[:metric_id])
  end

  def authorize_section
    authorize! :manage, :plans
  end

  def usage_limit_params
    params.require(:usage_limit)
  end
end
