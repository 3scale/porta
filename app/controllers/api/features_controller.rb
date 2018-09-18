class Api::FeaturesController < FrontendController
  before_action :authorize_plans
  before_action :find_plan
  before_action :find_feature, :only => [:edit, :update, :destroy]

  layout false

  def new
    @feature = collection.build :scope => @plan.class.to_s, :featurable => @plan.issuer

    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @feature = collection.build params[:feature].merge(:scope => @plan.class.to_s, :featurable => @plan.issuer)

    respond_to do |format|
      if @feature.save
        format.js
      else
        format.js { render :action => 'error' }
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    respond_to do |format|
      if @feature.update_attributes(params[:feature])
        format.js
      else
        format.js { render :action => 'error' }
      end
    end
  end

  def destroy
    @feature.destroy

    # redirect_to  edit_admin_plan_url(@plan, :type => @plan.class.to_s.underscore)
    # TODO: Solve problem of charging with AJAX
    respond_to do |format|
      format.js
    end
  end

  protected

  def collection
    @plan.issuer.features
  end

  def find_feature
    @feature = collection.find(params[:id])
  end

  def find_plan
    @plan = current_account.provided_plans.find params[:plan_id]
  end

  def authorize_plans
    authorize! :manage, :plans
  end

end
