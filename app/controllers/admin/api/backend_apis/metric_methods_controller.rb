# frozen_string_literal: true

class Admin::Api::BackendApis::MetricMethodsController < Admin::Api::BackendApis::MetricsController
  representer Method

  ### INDEX
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/metrics/{metric_id}/methods.json"
  ##~ e.responseClass = "List[methods]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Backend API Method List"
  ##~ op.description = "List the methods of a metric that belongs to a backend api. Methods are metrics that are children of a parent metric."
  ##~ op.group = "metric_method"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  #

  ### CREATE
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/metrics/{metric_id}/methods.json"
  ##~ e.responseClass = "method"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Backend API Method Create"
  ##~ op.description = "Creates a method under a metric that belongs to a backend api."
  ##~ op.group = "metric_method"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  ##~ op.parameters.add :name => "friendly_name", :description => "Descriptive Name of the metric.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "system_name", :description => "System Name of the metric. If blank a system_name will be generated for you from the friendly_name parameter", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "unit", :description => "Measure unit of the metric.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the metric.", :dataType => "text", :allowMultiple => false, :required => false, :paramType => "query"
  #

  ### SHOW
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/metrics/{metric_id}/methods/{id}.json"
  ##~ e.responseClass = "method"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Backend API Method Read"
  ##~ op.description = "Returns the method of a metric that belongs to a backend api."
  ##~ op.group = "metric_method"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  ##~ op.parameters.add @parameter_method_id_by_id
  #

  ### UPDATE
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/metrics/{metric_id}/methods/{id}.json"
  ##~ e.responseClass = "method"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Backend API Method Update"
  ##~ op.description = "Updates a method of a metric that belongs to a backend api."
  ##~ op.group = "metric_method"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  ##~ op.parameters.add @parameter_method_id_by_id
  ##~ op.parameters.add :name => "friendly_name", :description => "Name of the method.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "unit", :description => "Measure unit of the method.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the method.", :dataType => "text", :allowMultiple => false, :required => false, :paramType => "query"
  #

  ### DESTROY
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/metrics/{metric_id}/methods/{id}.json"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Backend API Method Delete"
  ##~ op.description = "Deletes the method of a metric that belongs to a backend api."
  ##~ op.group = "metric_method"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  ##~ op.parameters.add @parameter_method_id_by_id
  #

  private

  def metrics_collection
    @metrics_collection ||= backend_api.metrics.find(params[:metric_id]).children
  end
end
