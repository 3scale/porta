# frozen_string_literal: true

class Stats::Data::BackendApisController < Stats::Data::BaseController
  before_action :set_source

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
