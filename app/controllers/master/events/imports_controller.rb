class Master::Events::ImportsController < Master::BaseController
  include SiteAccountSupport
  respond_to :xml

  before_action :check_shared_secret

  def create
    ::Events.async_fetch_backend_events!

    render :nothing => true, :status => :ok
  end

  private

  def check_shared_secret
    permitted_params = params.permit(%i[secret])
    head(403) unless permitted_params[:secret] == Events.shared_secret
  end
end
