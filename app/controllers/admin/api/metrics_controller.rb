class Admin::Api::MetricsController < Admin::Api::MetricsBaseController

  wrap_parameters Metric, include: [ :name, :system_name, :friendly_name, :unit, :description ]
  representer Metric

  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/metrics.xml"
  ##~ e.responseClass = "List[metric]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Metric List"
  ##~ op.description = "Returns the list of metrics of a service."
  ##~ op.group = "metric"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  #
  def index
    respond_with(metrics)
  end

  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Metric Create"
  ##~ op.description = "Creates a metric on a service. All metrics are scoped by service."
  ##~ op.group = "metric"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add :name => "friendly_name", :description => "Descriptive Name of the metric.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "system_name", :description => "System Name of the metric. This is the name used to report API requests with the Service Management API. If blank a system_name will be generated for you from the friendly_name parameter", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "name", :description => "DEPRECATED: Please use system_name parameter", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "unit", :description => "Measure unit of the metric.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the metric.", :dataType => "text", :allowMultiple => false, :required => false, :paramType => "query"
  #
  def create
    metric = metrics.create(metric_params)

    respond_with(metric)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/metrics/{id}.xml"
  ##~ e.responseClass = "metric"
  #
  ##~ op = e.operations.add
  ##~ op.nickname   = "service_metric"
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Metric Read"
  ##~ op.description = "Returns the metric of a service."
  ##~ op.group = "metric"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id
  #
  def show
    respond_with(metric)
  end

  ##~ op = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Metric Update"
  ##~ op.description = "Updates the metric of a service."
  ##~ op.group = "metric"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id
  ##~ op.parameters.add :name => "friendly_name", :description => "Name of the metric.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "unit", :description => "Measure unit of the metric.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the metric.", :dataType => "text", :allowMultiple => false, :required => false, :paramType => "query"
  #
  def update
    metric.update_attributes(metric_params)

    respond_with(metric)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Metric Delete"
  ##~ op.description = "Deletes the metric of a service. When you delete a metric or a method, it will also remove all the associated limits across application plans."
  ##~ op.group = "metric"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_metric_id_by_id
  #
  def destroy
    metric.destroy

    respond_with(metric)
  end

  protected
    def metric
      @metrics ||= metrics.find(params[:id])
    end
end
