class DeveloperPortal::Admin::Applications::AlertsController <  ::DeveloperPortal::BaseController

  include Liquid::TemplateSupport
  include ThreeScale::Search::Helpers

  before_action :find_application
  before_action :authorize_alerts

  activate_menu :dashboard, :applications

  liquify prefix: 'applications/alerts'.freeze
  self.builtin_template_scope = 'applications/alerts'

  def index
    alerts = Liquid::Drops::Collection.for_drop(Liquid::Drops::Alert).new(collection)

    assign_drops application:  @cinstance,
                 alerts: alerts
  end

  def all_read
    @alerts = collection.unread
    @alerts.update_all :state => 'read'

    flash[:notice] = 'All alerts were marked as read.'

    respond_to do |format|
      format.html { redirect_to url_for(:action => :index) }
      format.js
    end
  end

  def purge
    @alerts = collection
    @alerts.update_all :state => 'deleted'

    flash[:notice] = 'All alerts were deleted.'

    redirect_to url_for(:action => :index)
  end

  def read
    @alert = resource
    @alert.read

    redirect_to url_for(:action => :index)
  end

  def destroy
    @alert = resource

    @alert.delete!

    redirect_to url_for(:action => :index)
  end

  private

  def authorize_alerts
    authorize! :manage_alerts, @cinstance
  end

  def find_application
    @cinstance = current_account.bought_cinstances.find(params[:application_id])
  end

  def collection
    current_account.alerts.not_deleted.by_application(@cinstance).sorted.order_by(params[:sort], params[:direction])
  end

  def resource
    collection.find(params[:id])
  end

end
