class Stats::Data::ServicesController < Stats::Data::BaseController
  before_action :set_source

  ##~ sapi = source2swagger.namespace("Analytics API")
  ##
  ##~ e = sapi.apis.add
  ##~ e.path = "/stats/services/{service_id}/usage.{format}"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Service Usage by Metric"
  ##~ op.description = "Returns the usage data of a given metric (or method) of a service."
  ##~ op.group = "service_ops"
  #
  ##~ op.parameters.add @parameter_format
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id
  ##~ op.parameters.add @parameter_metric_name
  ##~ op.parameters.add @parameter_since
  ##~ op.parameters.add @parameter_period
  ##~ op.parameters.add @parameter_until
  ##~ op.parameters.add @parameter_granularity
  ##~ op.parameters.add @parameter_timezone
  ##~ op.parameters.add @parameter_skip_change
  #
  ##
  ##~ e = sapi.apis.add
  ##~ e.path = "/stats/services/{service_id}/top_applications.{format}"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Service Top Applications"
  ##~ op.description = "Returns usage and application data for the top 10 most active applications of a service."
  ##~ op.group = "service_ops"
  #
  ##~ op.parameters.add @parameter_format
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id
  ##~ op.parameters.add @parameter_since
  ##~ op.parameters.add @parameter_period
  ##~ op.parameters.add @parameter_metric_name
  #
  def top_applications
    options = slice_and_use_defaults(params, :metric_name, :period, :since, :timezone)

    begin
      @data = @source.top_clients(options)
    rescue Stats::InvalidParameterError => e
      render_error e.to_s, :status => :bad_request
    else

      respond_to do |format|
        format.json {render :json => @data}
        format.xml { render :layout => false}
        format.csv  do
          send_data(*Stats::Views::Csv::TopApplications.new(@data).to_send_data)
        end
      end
    end
  end

  def summary
    super
  end

  private

  def set_source
    begin
      services = (current_user || current_account).accessible_services
      @service = services.find(params[:service_id])
      @source  = Stats::Service.new(@service)

      authorize!(:show, @service) if current_user

    rescue ActiveRecord::RecordNotFound
      render_error "Service not found", :status => :not_found
    end
  end
end
