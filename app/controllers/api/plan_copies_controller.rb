class Api::PlanCopiesController < FrontendController

  before_action :find_plan
  before_action :authorize_manage_plans, only: %i[new create]

  def new
  end

  def create
    @plan = @original.copy(params[@type] || {})

    if @plan.save
      # TODO: DRY this in model
      @plans = @issuer.send("#{@type}s", true).not_custom

      @new_plan = @plan.class
    end

    respond_to do |format|
      format.js do
        if @plan.persisted?
          render :create
        else
          render :new
        end
      end
    end
  end

  private

  def find_plan
    @original = current_account.provided_plans.find(params[:plan_id])
    @type = @original.class.to_s.underscore
    @issuer = @original.issuer
    @service = @original.service if @original.respond_to?(:service)
  end

  def authorize_manage_plans
    authorize! :manage, :plans
  end

end
