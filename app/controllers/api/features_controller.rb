# frozen_string_literal: true

class Api::FeaturesController < FrontendController
  before_action :authorize_section

  before_action :find_plan
  before_action :find_service
  before_action :find_feature, only: %i[edit update destroy]

  layout false

  def new
    @feature = collection.build :scope => @plan.class.to_s, :featurable => @plan.issuer

    respond_to do |format|
      format.html
      format.js
    end
  end

  # TODO: return actual errors instead of showing generic warning (see _error.js.erb)
  def create
    @feature = collection.build(feature_params.merge(scope: @plan.class.to_s, featurable: @plan.issuer))

    flash.now[:success] = t('.success') if @feature.save

    respond_to :js
  end

  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  # TODO: return actual errors instead of showing generic warning (see _error.js.erb)
  def update
    flash.now[:success] = t('.success') if @feature.update(feature_params)

    respond_to :js
  end

  def destroy
    if @feature.destroy
      flash.now[:success] = t('.success')
    else
      flash.now[:danger] = t('.error')
    end

    # redirect_to  edit_admin_plan_url(@plan, :type => @plan.class.to_s.underscore)
    # TODO: Solve problem of charging with AJAX
    respond_to :js
  end

  protected

  def find_plan
    @plan = current_account.provided_plans.find params[:plan_id]
  end

  def find_service
    return unless @plan.respond_to?(:service)
    @service = current_user.accessible_services.find(@plan.issuer_id)
  end

  def find_feature
    @feature = collection.find(params[:id])
  end

  def collection
    @plan.issuer.features
  end

  def authorize_section
    authorize! :manage, :plans
  end

  def feature_params
    params.require(:feature).permit(:name, :system_name, :description)
  end
end
