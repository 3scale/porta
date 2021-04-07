# frozen_string_literal: true

# This will publish/hide all kinds of plans. AHEM.
class Api::PlansController < Api::PlansBaseController
  before_action :deny_on_premises_for_master, only: %i[publish hide]

  def publish
    # Only Application plans are implemented in React right now
    return old_publish unless @plan.type == 'ApplicationPlan'

    name = @plan.name
    json = {}
    if @plan.publish
      json[:notice] = "Plan #{name} was published."
      json[:plan] = @plan.decorate.index_table_data.to_json
      status = :ok
    else
      json[:error] = "Plan #{name} cannot be published."
      status = :not_acceptable
    end

    respond_to do |format|
      format.json { render json: json, status: status }
    end
  end

  def hide
    # Only Application plans are implemented in React right now
    return old_hide unless @plan.type == 'ApplicationPlan'

    name = @plan.name
    json = {}
    if @plan.hide
      json[:notice] = "Plan #{name} was hidden."
      json[:plan] = @plan.decorate.index_table_data.to_json
      status = :ok
    else
      json[:alert] = "Plan #{name} cannot be hidden."
      status = :not_acceptable
    end

    respond_to do |format|
      format.json { render json: json, status: status }
    end
  end

  private

  def collection
    current_account.provided_plans
  end

  def determine_plans_path
    case @plan.type
    when "ServicePlan"
      admin_service_service_plans_path @plan.service
    when "ApplicationPlan"
      admin_service_application_plans_path @plan.service
    when "AccountPlan"
      admin_account_plans_path
    else
      :back # let it fail.
    end
  end

  def old_publish
    ThreeScale::Deprecation.warn "This method will be removed once Plans has migrated to React"
    name = @plan.name
    if @plan.publish
      flash[:notice] = "Plan #{name} was published."
    else
      flash[:alert] = "Plan #{name} cannot be published."
    end

    redirect_back_or_to determine_plans_path
  end

  def old_hide
    ThreeScale::Deprecation.warn "This method will be removed once Plans has migrated to React"
    name = @plan.name
    if @plan.hide
      flash[:notice] = "Plan #{name} was hidden."
    else
      flash[:alert] = "Plan #{name} cannot be hidden."
    end

    redirect_back_or_to determine_plans_path
  end
end
