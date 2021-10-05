# frozen_string_literal: true

class Provider::Admin::BackendApis::MetricsController < Provider::Admin::BackendApis::BaseController
  include MetricParams

  before_action :find_metric, except: %i[new create index]

  activate_menu :backend_api, :methods_metrics
  sublayout 'api/service'

  helper_method :presenter

  def index; end

  def new
    @metric = collection.build
  end

  def create
    @metric = collection.build(create_params)
    if @metric.save
      flash[:notice] = "The #{metric_type} was created"
      redirect_to provider_admin_backend_api_metrics_path(@backend_api)
    else
      flash[:error] = "#{metric_type.capitalize} could not be created"
      render :new
    end
  end

  def edit; end

  def update
    if @metric.update_attributes(update_params)
      flash[:notice] = "The #{metric_type} was updated"
      redirect_to provider_admin_backend_api_metrics_path(@backend_api)
    else
      flash[:error] = "#{metric_type.capitalize} could not be updated"
      render :edit
    end
  end

  def destroy
    if @metric.destroy
      flash[:notice] = "The #{metric_type} was deleted"
      redirect_to provider_admin_backend_api_metrics_path(@backend_api)
    else
      flash[:error] = "The #{metric_type} could not be deleted"
      render :edit
    end
  end

  protected

  def presenter
    @presenter ||= Provider::Admin::BackendApis::MetricsIndexPresenter.new(backend_api: @backend_api, params: params)
  end

  def find_metric
    @metric = find_backend_api_metric_by(params[:id])
  end

  def find_backend_api_metric_by(id)
    @backend_api.metrics.find(id)
  end

  def metric_type
    @metric.child? ? 'method' : 'metric'
  end

  def collection
    metric_id = params[:metric_id]
    metric_id ? find_backend_api_metric_by(metric_id).children : @backend_api.metrics
  end
end
