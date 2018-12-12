class Stats::Data::ApplicationsController < Stats::Data::BaseController
  before_action :find_cinstance
  before_action :find_service
  before_action :set_source

  ##~ sapi = source2swagger.namespace("Analytics API")
  ##
  ##~ e = sapi.apis.add
  ##~ e.path = "/stats/applications/{application_id}/usage.{format}"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Application Usage by Metric"
  ##~ op.description = "Returns the usage data for a given metric (or method) of an application."
  ##~ op.group = "application_ops"
  #
  ##~ op.parameters.add @parameter_format
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_application_id
  ##~ op.parameters.add @parameter_metric_name
  ##~ op.parameters.add @parameter_since
  ##~ op.parameters.add @parameter_period
  ##~ op.parameters.add @parameter_until
  ##~ op.parameters.add @parameter_granularity
  ##~ op.parameters.add @parameter_timezone
  ##~ op.parameters.add @parameter_skip_change
  #


  def summary
    @metrics = @service.metrics.top_level.visible_for_plan(plan)
    @methods = @service.method_metrics.visible_for_plan(plan)
    respond_to do |format|
      format.html { render action: action }
      format.json { render json: metrics_with_methods }
    end
  end

  private

  def plan
    @plan ||= @cinstance.plan
  end

  def find_service
    @service = @cinstance.service

    authorize!(:show, @service) if current_user && current_account.provider?
  end

  def find_cinstance
    begin
      @cinstance = if current_account.buyer?
        #TODO: this allows a buyer to pass any app_id, and it will show no matter the app not being 'live'
        if params[:application_id]
          current_account.bought_cinstances.find(params[:application_id])
        else
          #TODO: it is better to use bought_cinstances.live.first as a default, in case this one is not 'live'
          current_account.bought_cinstance
        end
                   else
        current_account.provided_cinstances.find(params[:application_id])
      end
    rescue ActiveRecord::RecordNotFound
      render_error "Application not found", :status => :not_found
    end
  end

  def set_source
    @source = Stats::Client.new(@cinstance)
  end

  def metrics_with_methods
    {metrics: @metrics, methods: @methods}
  end
end
