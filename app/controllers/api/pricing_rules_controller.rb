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
    respond_to :js
  end

  def new
    @pricing_rule = @plan.pricing_rules.build(:metric => @metric)
    respond_to :html # will render in a colorbox
  end

  def create
    @pricing_rule = @plan.pricing_rules.build(pricing_rule_params)
    @pricing_rule.metric = @metric

    flash.now[:success] = t('.success') if @pricing_rule.save

    respond_to :js
  end

  def edit
    respond_to :html # will render in a colorbox
  end

  def update
    flash.now[:success] = t('.success') if @pricing_rule.update(pricing_rule_params)

    respond_to :js
  end

  def destroy
    if @pricing_rule.destroy
      flash.now[:success] = t('.success')
    else
      flash.now[:danger] = t('.error')
    end

    respond_to :js
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
