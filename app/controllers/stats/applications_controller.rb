class Stats::ApplicationsController < Stats::BaseController
  before_action :find_cinstance
  before_action :find_service
  before_action :find_buyer_account

  activate_menu :applications

  def show
    @metrics = @service.metrics.top_level
    @methods = @service.method_metrics

    respond_to do |format|
      format.html { render :show }
      format.json { render json: metrics_with_methods }
    end
  end

  private

  def find_cinstance
    @cinstance = current_account.provided_cinstances.find params[:id]
  end

  def find_service
    @service = @cinstance.service

    authorize!(:show, @cinstance.service)
  end

  def find_buyer_account
    @account = @cinstance.user_account
  end

  def metrics_with_methods
    {metrics: @metrics, methods: @methods}
  end
end
