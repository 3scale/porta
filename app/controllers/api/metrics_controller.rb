class Api::MetricsController < Api::BaseController
  include ServiceDiscovery::ControllerMethods

  before_action :find_service, except: [:toggle_visible, :toggle_limits_only_text, :toggle_enabled]
  before_action :find_plan_and_service, only: [:toggle_visible, :toggle_limits_only_text, :toggle_enabled]
  before_action :find_metric, except: [:new, :create, :index]
  before_action :build_metric, only: [:new, :create]

  activate_menu :serviceadmin, :integration, :methods_metrics
  sublayout 'api/service'

  def index
    respond_to do |format|
      format.html do
        @metrics = @service.metrics.top_level.includes(:proxy_rules)
        @methods = @service.method_metrics.includes(:proxy_rules)
        @hits_metric = @service.metrics.hits
      end
    end
  end

  def new
    respond_to do |format|
      format.html
    end
  end

  def create
    respond_to do |format|
      if @metric.save
        flash.now[:notice] = 'Metric has been created.'
        onboarding.bubble_update('metric')
        format.html do
          flash[:notice] = "The #{@metric.child? ? 'method' : 'metric'} was created"
          redirect_to admin_service_metrics_path(@service)
        end
      else
        format.html { render :new }
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    if @metric.update_attributes(params[:metric])
      respond_to do |format|
        format.html do
          flash[:notice] = "The #{@metric.child? ? 'method' : 'metric'} was updated"
          return redirect_to action: :index
        end
      end
    else
      respond_to do |format|
        format.html { render :edit }
      end
    end
  end

  def destroy
    if @metric.destroy
      flash[:notice] = "The #{@metric.child? ? 'method' : 'metric'} was deleted"
    else
      flash[:error] = 'The Hits metric cannot be deleted'
    end

    respond_to do |format|
      format.html do
        redirect_to action: :index
      end
    end
  end

  #TODO: move this one to own controller?
  def toggle_visible
    @metric.toggle_visible_for_plan @plan

    respond_to do |format|
      format.html { redirect_to edit_admin_application_plan_path(@plan) }
      format.js
    end
  end

  #TODO: move this one to own controller?
  def toggle_limits_only_text
    @metric.toggle_limits_only_text_for_plan @plan

    respond_to do |format|
      format.html { redirect_to edit_admin_application_plan_path(@plan) }
      format.js
    end
  end

  def toggle_enabled
    if @metric.enabled_for_plan? @plan
      @metric.disable_for_plan @plan
    else
      @metric.enable_for_plan @plan
    end

    respond_to do |format|
      format.html do
        if @metric.errors.present?
          flash[:error] = @metric.errors.full_messages.to_sentence
        end

        redirect_to edit_admin_application_plan_path(@plan)
      end
      format.js do
        @usage_limits = @plan.usage_limits.where(metric_id: @metric.id)
      end
    end
  end

  private

  def find_service
    service_id = params[:service_id]
    @service   = current_user.accessible_services.find(service_id) if service_id
  end

  def find_metric
    @metric = @service.metrics.find(params[:id])
  end

  def build_metric
    @metric = if params[:metric_id]
                @service.metrics.find(params[:metric_id]).children
              else
                @service.metrics
              end.build(params[:metric] || {})
  end

  def find_plan_and_service
    @plan = find_application_plan || find_end_user_plan
    @service = @plan.service if @plan
  end

  def find_application_plan
    id = params[:application_plan_id]
    current_account.application_plans.find(id) if id
  end

  def find_end_user_plan
    id = params[:end_user_plan_id]
    current_account.end_user_plans.find(id) if id
  end
end
