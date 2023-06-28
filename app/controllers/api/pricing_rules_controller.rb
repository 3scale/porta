# frozen_string_literal: true

class Api::PricingRulesController < FrontendController
  before_action :authorize_section
  before_action :authorize_action, except: :index

  before_action :find_plan
  before_action :find_service
  before_action :find_metric, only: %i[index new create]
  before_action :find_pricing_rule, only: %i[edit update destroy]

  def index
    @pricing_rules = @plan.pricing_rules.where(metric_id: @metric.id)
  end

  def new
    @pricing_rule = @plan.pricing_rules.build(:metric => @metric)
  end

  def create
    @pricing_rule = @plan.pricing_rules.build(pricing_rule_params)
    @pricing_rule.metric = @metric

    respond_to do |format|
      if @pricing_rule.save
        format.js
        format.html { redirect_to(admin_application_plan_metric_pricing_rules_path(@plan, @metric), :notice => 'Pricing rule was successfully created.') }
      else
        format.js { render :action => 'error' }
        format.html { render :action => "new" }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @pricing_rule.update(pricing_rule_params)
        format.js
        format.html { redirect_to(edit_admin_application_plan_pricing_rule_path(@plan, @pricing_rule), :notice => 'Pricing rule was successfully updated.')}
      else
        format.js { render :action => 'error' }
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @pricing_rule.destroy

    respond_to do |format|
      format.js
    end
  end

  private

  def find_plan
    @plan = current_account.provided_plans.find params[:application_plan_id]
  end

  def find_service
    return unless @plan.respond_to?(:service)
    @service = current_user.accessible_services.find(@plan.issuer_id)
  end

  def find_metric
    @metric = @plan.all_metrics.find(params[:metric_id])
  end

  def find_pricing_rule
    @pricing_rule = @plan.pricing_rules.find(params[:id])
  end

  def authorize_section
    authorize! :manage, :plans
  end

  def authorize_action
    authorize! :create, :plans
  end

  def pricing_rule_params
    params.require(:pricing_rule)
  end
end
