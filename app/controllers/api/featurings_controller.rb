class Api::FeaturingsController < FrontendController
  before_action :authorize_plans

  before_action :find_plan
  before_action :find_feature

  def create
    @plan.features << @feature
    @plan.save!
    @notice = 'Feature has been enabled.'
    respond_to do |format|
      format.js { render :action => 'change' }
    end
  end

  def destroy
    @plan.features.delete(@feature)
    @notice = 'Feature has been disabled.'

    respond_to do |format|
      format.js { render :action => 'change' }
    end
  end

  private

  def find_plan
    @plan = current_account.provided_plans.find params[:plan_id]
  end

  def find_feature
    @feature = @plan.issuer.features.find(params[:id])
  end

  def authorize_plans
    authorize! :manage, :plans
  end

end
