# frozen_string_literal: true

class Api::UsageLimitsController < FrontendController
  before_action :authorize_section
  before_action :authorize_action, except: :index

  before_action :find_plan
  before_action :find_service
  before_action :find_metric, only: %i[index new create]
  before_action :find_usage_limit, only: %i[edit update destroy]

  delegate :onboarding, to: :current_account

  def index
    @usage_limits = @plan.usage_limits.where(metric_id: @metric.id)
    respond_to(:js)
  end

  def new
    @usage_limit = @metric.usage_limits.build(:plan => @plan)
    respond_to :html # will render in a colorbox
  end

  def create
    @usage_limit = @metric.usage_limits.build(usage_limit_params)
    @usage_limit.plan = @plan
    @usage_limit.save

    flash.now[:success] = t('.success') if @usage_limit.save

    respond_to :js
  end

  def edit
    respond_to :html # will render in a colorbox
  end

  def update
    flash.now[:success] = t('.success') if @usage_limit.update(usage_limit_params)

    respond_to :js
  end

  def destroy
    if @usage_limit.destroy
      flash.now[:success] = t('.success')
    else
      flash.now[:danger] = t('.error')
    end

    respond_to(:js)
  end

  private

  def find_plan
    @plan = current_account.application_plans.find(params[:application_plan_id])
  end

  def find_service
    return unless @plan.respond_to?(:service)
    @service = current_user.accessible_services.find(@plan.issuer_id)
  end

  def find_metric
    @metric = @plan.all_metrics.find(params[:metric_id])
  end

  def find_usage_limit
    @usage_limit = @plan.usage_limits.find(params[:id])
  end

  def authorize_section
    authorize! :manage, :plans
  end

  def authorize_action
    authorize! :create, :plans
  end

  def usage_limit_params
    params.require(:usage_limit)
  end
end
