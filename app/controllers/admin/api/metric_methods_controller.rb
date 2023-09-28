class Admin::Api::MetricMethodsController < Admin::Api::MetricsBaseController

  wrap_parameters Metric, include: [ :name, :system_name, :friendly_name, :unit, :description ]
  representer Method

  # Service Method List
  # GET /admin/api/services/{service_id}/metrics/{metric_id}/methods.xml
  def index
    respond_with(metric_methods)
  end

  # Service Method Create
  # POST /admin/api/services/{service_id}/metrics/{metric_id}/methods.xml
  def create
    metric_method = metric_methods.create(create_params)
    respond_with(metric_method)
  end

  # Service Method Read
  # GET /admin/api/services/{service_id}/metrics/{metric_id}/methods/{id}.xml
  def show
    respond_with(metric_method)
  end

  # Service Method Update
  # PUT /admin/api/services/{service_id}/metrics/{metric_id}/methods/{id}.xml
  def update
    metric_method.update(update_params)

    respond_with(metric_method)
  end

  # Service Method Delete
  # DELETE /admin/api/services/{service_id}/metrics/{metric_id}/methods/{id}.xml
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
