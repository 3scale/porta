# frozen_string_literal: true

class Api::MetricVisibilitiesController < FrontendController
  before_action :authorize_section

  before_action :find_plan
  before_action :find_service
  before_action :find_metric

  def toggle_visible
    @metric.toggle_visible_for_plan(@plan)

    if (errors = @metric.errors.presence)
      flash[:danger] = errors.full_messages.to_sentence
    else
      state = @metric.visible_in_plan?(@plan) ? :visible : :invisible
      flash[:success] = t(".#{state}", type: @type, name: @metric.friendly_name)
    end

    respond_to do |format|
      format.html { redirect_to edit_admin_application_plan_path(@plan) }
      format.js { render action: 'change' }
    end
  end

  def toggle_limits_only_text
    @metric.toggle_limits_only_text_for_plan(@plan)

    if (errors = @metric.errors.presence)
      flash[:danger] = errors.full_messages.to_sentence
    else
      state = @metric.limits_only_text_in_plan?(@plan) ? :only_text : :text_icons
      flash[:success] = t(".#{state}", type: @type, name: @metric.friendly_name)
    end

    respond_to do |format|
      format.html { redirect_to edit_admin_application_plan_path(@plan) }
      format.js { render action: 'change' }
    end
  end

  def toggle_enabled # rubocop:disable Metrics/AbcSize
    @metric.toggle_enabled_for_plan(@plan)

    if (errors = @metric.errors.presence)
      flash[:danger] = errors.full_messages.to_sentence
    else
      state = @metric.enabled_for_plan?(@plan) ? :enabled : :disabled
      flash[:success] = t(".#{state}", type: @type, name: @metric.friendly_name)
    end

    respond_to do |format|
      format.html { redirect_to edit_admin_application_plan_path(@plan) }
      format.js do
        @usage_limits = @plan.usage_limits.where(metric_id: @metric.id)
        render action: 'change'
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
    @type = @metric.method_metric? ? 'Method' : 'Metric'
  end

  def authorize_section
    authorize! :manage, :plans
  end

  def usage_limit_params
    params.require(:usage_limit)
  end
end
