# frozen_string_literal: true

class Admin::Api::BackendApis::MetricMethodsController < Admin::Api::BaseController
  wrap_parameters Metric
  representer Method

  self.access_token_scopes = :account_management

  before_action :authorize

  clear_respond_to
  respond_to :json

  def index
    respond_with(metric_methods)
  end

  def create
    metric_method = metric_methods.create(create_params)
    respond_with(metric_method)
  end

  def show
    respond_with(metric_method)
  end

  def update
    metric_method.update(update_params)
    respond_with(metric_method)
  end

  def destroy
    metric_method.destroy
    respond_with(metric_method)
  end

  private

  DEFAULT_PARAMS = %i[friendly_name unit description].freeze
  private_constant :DEFAULT_PARAMS

  def metric_method
    @metric_method ||= metric_methods.find(params[:id])
  end

  def metric_methods
    @metric_methods ||= parent_metric.children
  end

  def parent_metric
    @parent_metric ||= backend_api.metrics.find(params[:metric_id])
  end

  def backend_api
    @backend_api ||= current_account.backend_apis.find(params[:backend_api_id])
  end

  def authorize
    authorize! :manage, BackendApi
  end

  def create_params
    params.require(:metric).permit(DEFAULT_PARAMS | %i[system_name])
  end

  def update_params
    params.require(:metric).permit(DEFAULT_PARAMS)
  end
end
