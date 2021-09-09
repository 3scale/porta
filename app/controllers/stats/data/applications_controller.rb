class Stats::Data::ApplicationsController < Stats::Data::BaseController
  before_action :find_cinstance
  before_action :find_service
  before_action :set_source


  def summary
    @metrics = @service.metrics.top_level
    @methods = @service.method_metrics
    respond_to do |format|
      format.html { render action: action }
      format.json { render json: metrics_with_methods }
    end
  end

  private

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
