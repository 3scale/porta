# frozen_string_literal: true

class Provider::Admin::BackendApis::Stats::BaseController < Stats::BaseController

  before_action :authorize_monitoring
  before_action :find_backend_api

  activate_menu :backend_api, :monitoring

  sublayout :stats

  def index
    @metrics = @backend_api.metrics.top_level
    @methods = @backend_api.method_metrics

    respond_to do |format|
      format.html { render :index }
      format.json { render json: metrics_with_methods }
    end
  end

  protected

  def authorize_monitoring
    authorize! :manage, :monitoring
  end

  def find_backend_api
    @backend_api = collection.find(params.require(:backend_api_id))
    authorize! :show, @backend_api
  end

  def collection
    current_account.backend_apis.accessible
  end

  def metrics_with_methods
    {metrics: @metrics, methods: @methods}
  end
end
