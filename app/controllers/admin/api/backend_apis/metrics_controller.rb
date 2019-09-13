# frozen_string_literal: true

class Admin::Api::BackendApis::MetricsController < Admin::Api::BaseController
  wrap_parameters Metric
  representer Metric

  self.access_token_scopes = :account_management

  before_action :authorize

  clear_respond_to
  respond_to :json


  ##~ @parameter_backend_api_id_by_id_name = { :name => "backend_api_id", :description => "ID of the backend API.", :dataType => "int", :required => true, :paramType => "path" }


  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/metrics.json"
  ##~ e.responseClass = "List[metric]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Backend API Metric List"
  ##~ op.description = "Returns the list of metrics of a backend api."
  ##~ op.group = "metric"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  #
  def index
    respond_with(backend_api.metrics)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/metrics/{id}.json"
  ##~ e.responseClass = "metric"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Backend API Metric Read"
  ##~ op.description = "Returns the metric of a backend api."
  ##~ op.group = "metric"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id
  #
  def show
    respond_with(metric)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/metrics.json"
  ##~ e.responseClass = "metric"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Backend API Metric Create"
  ##~ op.description = "Creates a metric on a backend api."
  ##~ op.group = "metric"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add :name => "friendly_name", :description => "Descriptive Name of the metric.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "system_name", :description => "System Name of the metric. If blank a system_name will be generated for you from the friendly_name parameter", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "unit", :description => "Measure unit of the metric.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the metric.", :dataType => "text", :allowMultiple => false, :required => false, :paramType => "query"
  #
  def create
    metric = backend_api.metrics.create(create_params)
    respond_with(metric)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/metrics/{id}.json"
  ##~ e.responseClass = "metric"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Backend API Metric Update"
  ##~ op.description = "Updates the metric of a backend api."
  ##~ op.group = "metric"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id
  ##~ op.parameters.add :name => "friendly_name", :description => "Name of the metric.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "unit", :description => "Measure unit of the metric.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the metric.", :dataType => "text", :allowMultiple => false, :required => false, :paramType => "query"
  #
  def update
    metric.update(update_params)
    respond_with(metric)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/metrics/{id}.json"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Backend API Metric Delete"
  ##~ op.description = "Deletes the metric of a backend api. When you delete a metric or a method, it will also remove all the associated limits."
  ##~ op.group = "metric"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id
  #
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
