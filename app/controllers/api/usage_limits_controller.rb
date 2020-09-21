# frozen_string_literal: true

class Api::UsageLimitsController < FrontendController
  before_action :find_plan
  before_action :find_metric, :only => [:index, :new, :create]
  before_action :find_usage_limit, :only => [:edit, :update, :destroy]

  delegate :onboarding, to: :current_account

  def index
    @usage_limits = @plan.usage_limits.where(metric_id: @metric.id)
    respond_to(:js)
  end

  def new
    @usage_limit = @metric.usage_limits.build(:plan => @plan)
    respond_to(:html)
  end

  def create
    @usage_limit = @metric.usage_limits.build(params[:usage_limit])
    @usage_limit.plan = @plan
    @usage_limit.save

    respond_to do |format|
      if @usage_limit.save
        flash.now[:notice] = 'Usage Limit has been created.'
        format.js
      else
        format.js { render :action => 'error' }
      end
    end
  end

  def edit
    respond_to(:html)
  end

  def update
    if @usage_limit.update_attributes(params[:usage_limit])
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js { render :action => 'error' }
      end
    end
  end

  def destroy
    @usage_limit.destroy
    respond_to(:js)
  end

  private

  def find_plan
    @plan = current_account.application_plans.find(params[:application_plan_id])
  end

  def find_metric
    @metric = @plan.all_metrics.find(params[:metric_id])
  end

  def find_usage_limit
    @usage_limit = @plan.usage_limits.find(params[:id])
  end
end
