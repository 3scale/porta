# frozen_string_literal: true

class Provider::Admin::BackendApis::MetricsController < Provider::Admin::BackendApis::BaseController
  before_action :find_metric, except: %i[new create index]

  activate_menu :backend_api, :methods_metrics
  sublayout 'api/service'

  def index
    @metrics = @backend_api.top_level_metrics.includes(:proxy_rules)
  end

  def new
    @metric = collection.build
  end

  def create
    @metric = collection.build(metric_params)
    if @metric.save
      onboarding.bubble_update('metric')
      flash[:notice] = "The #{metric_type} was created"
      redirect_to provider_admin_backend_api_metrics_path(@backend_api)
    else
      flash[:error] = "#{metric_type.capitalize} could not be created"
      render :new
    end
  end

  def edit; end

  def update
    if @metric.update_attributes(metric_params)
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

  helper_method :bubbles
  delegate :onboarding, to: :current_account

  def bubbles
    onboarding.persisted? ? onboarding.bubbles : []
  end

  private

  def find_metric
    @metric = find_backend_api_metric_by(params[:id])
  end

  def find_backend_api_metric_by(id)
    @backend_api.metrics.find(id)
  end

  def metric_params
    params.require(:metric).permit(:friendly_name, :system_name, :unit, :description)
  end

  def metric_type
    @metric.child? ? 'method' : 'metric'
  end

  def collection
    metric_id = params[:metric_id]
    metric_id ? find_backend_api_metric_by(metric_id).children : @backend_api.metrics
  end
end
