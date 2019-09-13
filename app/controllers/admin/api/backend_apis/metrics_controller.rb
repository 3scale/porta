# frozen_string_literal: true

class Admin::Api::BackendApis::MetricsController < Admin::Api::BaseController
  wrap_parameters Metric
  representer Metric

  self.access_token_scopes = :account_management

  before_action :authorize

  clear_respond_to
  respond_to :json

  def index
    respond_with(backend_api.metrics)
  end

  def show
    respond_with(metric)
  end

  def create
    metric = backend_api.metrics.create(create_params)
    respond_with(metric)
  end

  def update
    metric.update(update_params)
    respond_with(metric)
  end

  def destroy
    metric.destroy
    respond_with(metric)
  end

  private

  DEFAULT_PARAMS = %i[friendly_name unit description].freeze
  private_constant :DEFAULT_PARAMS

  def metric
    @metric ||= backend_api.metrics.find(params[:id])
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
