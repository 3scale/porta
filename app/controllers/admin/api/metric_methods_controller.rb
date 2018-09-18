class Admin::Api::MetricMethodsController < Admin::Api::MetricsBaseController

  wrap_parameters Metric, include: [ :name, :system_name, :friendly_name, :unit, :description ]
  representer Method

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/metrics/{metric_id}/methods.xml"
  ##~ e.responseClass = "List[methods]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Method List"
  ##~ op.description = "List the methods of a metric. Methods are metrics that are children of a parent metric."
  ##~ op.group = "metric_method"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  #
  def index
    respond_with(metric_methods)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/metrics/{metric_id}/methods.xml"
  ##~ e.responseClass = "method"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Method Create"
  ##~ op.description = "Creates a method under a metric."
  ##~ op.group = "metric_method"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  ##~ op.parameters.add :name => "friendly_name", :description => "Name of the method.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "system_name", :description => "System Name of the metric. This is the name used to report API requests with the Service Management API. If blank, a system_name will be generated for you from the friendly_name parameter", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "unit", :description => "Measure unit of the method.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the method.", :dataType => "text", :allowMultiple => false, :required => false, :paramType => "query"
  #
  def create
    metric_method = metric_methods.create(metric_params)
    respond_with(metric_method)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/metrics/{metric_id}/methods/{id}.xml"
  ##~ e.responseClass = "method"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Method Read"
  ##~ op.description = "Returns the method of a metric."
  ##~ op.group = "metric_method"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  ##~ op.parameters.add @parameter_method_id_by_id
  #
  def show
    respond_with(metric_method)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/metrics/{metric_id}/methods/{id}.xml"
  ##~ e.responseClass = "method"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Method Update"
  ##~ op.description = "Updates a method of a metric."
  ##~ op.group = "metric_method"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  ##~ op.parameters.add @parameter_method_id_by_id
  ##~ op.parameters.add :name => "friendly_name", :description => "Name of the method.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "unit", :description => "Measure unit of the method.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the method.", :dataType => "text", :allowMultiple => false, :required => false, :paramType => "query"
  #
  def update
    metric_method.update_attributes(metric_params)

    respond_with(metric_method)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/metrics/{metric_id}/methods/{id}.xml"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Method Delete"
  ##~ op.description = "Deletes the method of a metric."
  ##~ op.group = "metric_method"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id_name
  ##~ op.parameters.add @parameter_method_id_by_id
  #
  def destroy
    metric_method.destroy

    respond_with(metric_method)
  end

  protected
    def metric
      @metric ||= metrics.find(params[:metric_id])
    end

    def metric_method
      @metric_method ||= metric_methods.find(params[:id])
    end

    def metric_methods
      @metric_methods ||= metric.children
    end
end
