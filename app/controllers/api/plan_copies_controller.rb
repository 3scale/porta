# frozen_string_literal: true

class Api::PlanCopiesController < FrontendController
  before_action :find_plan
  before_action :find_service
  before_action :authorize_section, only: %i[new create]
  before_action :authorize_action, only: %i[new create]

  def create
    @plan = @original.copy(params[@type] || {})

    respond_to do |format|
      if @plan.save && @plan.persisted?
        json = { notice: 'Plan copied.' }
        json[:plan] = @plan.decorate.index_table_data.to_json
        format.json { render json: json, status: :created }
      else
        json = { error: 'Plan could not be copied.' }
        format.json { render json: json, status: :unprocessable_entity }
      end
    end
  end

  private

  def find_plan
    @original = current_account.provided_plans.find(params[:plan_id])
    @type = @original.class.to_s.underscore
    @issuer = @original.issuer
  end

  def find_service
    return unless @original.respond_to?(:service)

    @service = current_user.accessible_services.find(@original.issuer_id)
  end

  def authorize_section
    authorize! :manage, :plans
  end

  def authorize_action
    authorize! :create, :plans
  end
end
