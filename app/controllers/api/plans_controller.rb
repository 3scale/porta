# frozen_string_literal: true

# This will publish/hide all kinds of plans. AHEM.
class Api::PlansController < Api::PlansBaseController
  before_action :deny_on_premises_for_master, only: %i[publish hide]

  def publish
    name = @plan.name
    json = {}
    if @plan.publish
      json[:success] = t('.success', name: name)
      json[:plan] = @plan.decorate.index_table_data.to_json
      status = :ok
    else
      json[:error] = t('.error', name: name)
      status = :not_acceptable
    end

    respond_to do |format|
      format.json { render json: json, status: status }
    end
  end

  def hide
    name = @plan.name
    json = {}
    if @plan.hide
      json[:success] = t('.success', name: name)
      json[:plan] = @plan.decorate.index_table_data.to_json
      status = :ok
    else
      json[:error] = t('.error', name: name)
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
end
