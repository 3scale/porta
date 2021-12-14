# frozen_string_literal: true

class Api::MetricsController < Api::BaseController
  include ServiceDiscovery::ControllerMethods
  include MetricParams

  before_action :find_service
  before_action :find_metric, only: %i[edit update destroy]

  activate_menu :serviceadmin, :integration, :methods_metrics
  sublayout 'api/service'

  helper_method :presenter

  attr_reader :service

  delegate :metrics, to: :service, prefix: true

  def index; end

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
          flash[:notice] = "The #{method_or_metric} was created"
          redirect_to admin_service_metrics_path(@service, tab: "#{method_or_metric}s")
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
          flash[:notice] = "The #{method_or_metric} was updated"
          redirect_to admin_service_metrics_path(@service, tab: "#{method_or_metric}s")
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
      flash[:notice] = "The #{method_or_metric} was deleted"
    else
      flash[:error] = 'The Hits metric cannot be deleted'
    end

    respond_to do |format|
      format.html do
        redirect_to admin_service_metrics_path(@service, tab: "#{method_or_metric}s")
      end
    end
  end

  protected

  def find_service
    service_id = params[:service_id]
    @service   = current_user.accessible_services.find(service_id) if service_id
  end

  def find_metric
    @metric = service_metrics.find(params[:id])
  end

  def collection
    metric_id = params[:metric_id]
    metric_id ? service_metrics.find(metric_id).children : service_metrics
  end

  def presenter
    @presenter ||= Api::MetricsIndexPresenter.new(service: @service, params: params)
  end

  def method_or_metric
    @metric.child? ? 'method' : 'metric'
  end
end
