# frozen_string_literal: true

class Api::MetricsController < Api::BaseController
  include ServiceDiscovery::ControllerMethods
  include MetricParams

  before_action :find_service
  before_action :find_metric, only: %i[edit update destroy]

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
    @metric = collection.build
    respond_to do |format|
      format.html
    end
  end

  def create
    @metric = collection.build(create_params)
    respond_to do |format|
      if @metric.save
        flash.now[:notice] = 'Metric has been created.'
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
    if @metric.update_attributes(update_params)
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

  private

  def find_service
    service_id = params[:service_id]
    @service   = current_user.accessible_services.find(service_id) if service_id
  end

  attr_reader :service
  delegate :metrics, to: :service, prefix: true

  def find_metric
    @metric = service_metrics.find(params[:id])
  end

  def collection
    metric_id = params[:metric_id]
    metric_id ? service_metrics.find(metric_id).children : service_metrics
  end
end
