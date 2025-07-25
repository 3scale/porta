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
  end

  # TODO: DRY this, similar to app/controllers/provider/admin/backend_apis/metrics_controller.rb#create
  def create
    @metric = collection.build(create_params)
    if @metric.save
      redirect_to admin_service_metrics_path(@service, tab: "#{method_or_metric}s"), success: t('.success', type: method_or_metric)
    else
      flash.now[:danger] = t('.error', type: method_or_metric)
      render :new
    end
  end

  def edit; end

  def update
    if @metric.update(update_params)
      redirect_to admin_service_metrics_path(@service, tab: "#{method_or_metric}s"), success: t('.success', type: method_or_metric)
    else
      render :edit
    end
  end

  def destroy
    if @metric.destroy
      flash[:success] = t('.success', type: method_or_metric)
    else
      flash[:danger] = @metric.errors.full_messages.to_sentence
    end

    redirect_to admin_service_metrics_path(@service, tab: "#{method_or_metric}s")
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
