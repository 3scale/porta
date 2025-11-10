# frozen_string_literal: true

class Provider::Admin::BackendApis::MetricsController < Provider::Admin::BackendApis::BaseController
  include MetricParams

  before_action :find_metric, except: %i[new create index]

  activate_menu :backend_api, :methods_metrics

  helper_method :presenter

  attr_reader :backend_api

  delegate :metrics, to: :backend_api, prefix: true

  def index; end

  def new
    @metric = collection.build
  end

  # TODO: DRY this, similar to app/controllers/api/metrics_controller.rb#create
  def create
    @metric = collection.build(create_params)
    if @metric.save
      redirect_to provider_admin_backend_api_metrics_path(@backend_api, tab: "#{metric_type}s"), success: t('.success', metric_type: metric_type)
    else
      flash.now[:danger] = t('.error', metric_type: metric_type)
      render :new
    end
  end

  def edit; end

  def update
    if @metric.update(update_params)
      redirect_to provider_admin_backend_api_metrics_path(@backend_api, tab: "#{metric_type}s"), success: t('.success', metric_type: metric_type)
    else
      flash.now[:danger] = t('.error', metric_type: metric_type)
      render :edit
    end
  end

  def destroy
    if @metric.destroy
      redirect_to provider_admin_backend_api_metrics_path(@backend_api, tab: "#{metric_type}s"), success: t('.success', metric_type: metric_type)
    else
      flash.now[:danger] = t('.error', metric_type: metric_type)
      render :edit
    end
  end

  private

  def find_metric
    @metric = backend_api_metrics.find(params[:id])
  end

  def metric_type
    @metric.child? ? 'method' : 'metric'
  end

  def collection
    metric_id = params[:metric_id]
    metric_id ? backend_api_metrics.find(metric_id).children : backend_api_metrics
  end

  def presenter
    @presenter ||= Provider::Admin::BackendApis::MetricsIndexPresenter.new(backend_api: backend_api, params: params)
  end
end
