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
        onboarding.bubble_update('limit')
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
    @plan = find_application_plan || find_end_user_plan
  end

  def find_application_plan
    id = params[:application_plan_id]
    current_account.application_plans.find(id) if id
  end

  def find_end_user_plan
    id = params[:end_user_plan_id]
    current_account.end_user_plans.find(id) if id
  end


  def find_metric
    @metric = @plan.metrics.find(params[:metric_id])
  end

  def find_usage_limit
    @usage_limit = @plan.usage_limits.find(params[:id])
  end
end
