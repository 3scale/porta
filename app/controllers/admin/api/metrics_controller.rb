class Admin::Api::MetricsController < Admin::Api::MetricsBaseController

  wrap_parameters Metric, include: [ :name, :system_name, :friendly_name, :unit, :description ]
  representer Metric

  # Service Metric List
  # GET /admin/api/services/{service_id}/metrics.xml
  def index
    respond_with(metrics)
  end

  # Service Metric Create
  # POST /admin/api/services/{service_id}/metrics.xml
  def create
    metric = metrics.create(create_params)

    respond_with(metric)
  end

  # Service Metric Read
  # GET /admin/api/services/{service_id}/metrics/{id}.xml
  def show
    respond_with(metric)
  end

  # Service Metric Update
  # PUT /admin/api/services/{service_id}/metrics/{id}.xml
  def update
    metric.update_attributes(update_params)

    respond_with(metric)
  end

  # Service Metric Delete
  # DELETE /admin/api/services/{service_id}/metrics/{id}.xml
  def destroy
    metric.destroy

    respond_with(metric)
  end

  protected
    def metric
      @metrics ||= metrics.find(params[:id])
    end
end
