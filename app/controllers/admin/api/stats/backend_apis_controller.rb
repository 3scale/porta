# frozen_string_literal: true

class Admin::Api::Stats::BackendApisController < Admin::Api::Stats::BaseController
  before_action :set_source

  ##~ sapi = source2swagger.namespace("Analytics API")
  ##
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/stats/backend_apis/{backend_api_id}/usage.json"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Backend Traffic by Metric"
  ##~ op.description = "Returns the traffic data of a given metric (or method) of a backend."
  ##~ op.group = "backend_api_ops"
  #
  ##~ op.parameters.add @parameter_format
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add @parameter_backend_api_metric_name
  ##~ op.parameters.add @parameter_since
  ##~ op.parameters.add @parameter_period
  ##~ op.parameters.add @parameter_until
  ##~ op.parameters.add @parameter_granularity
  ##~ op.parameters.add @parameter_timezone
  ##~ op.parameters.add @parameter_skip_change
  #

  private

  def set_source
    backend_apis = current_account.backend_apis.accessible
    @backend_api = backend_apis.find(params[:backend_api_id])
    @source  = Stats::BackendApi.new(@backend_api)

    authorize!(:show, @backend_api) if current_user
  end

  def slice_and_use_defaults(params, *allowed)
    options = super(params, *allowed)

    return options unless options.key?(:metric_name)

    extended_system_name = Metric.build_extended_system_name(options[:metric_name], owner_id: params[:backend_api_id])
    options[:metric_name] = extended_system_name

    options
  end
end
