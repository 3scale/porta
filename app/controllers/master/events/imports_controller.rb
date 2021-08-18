class Master::Events::ImportsController < Master::BaseController
  include SiteAccountSupport
  respond_to :xml

  before_action :check_shared_secret

  def create
    ::Events.async_fetch_backend_events!

    head :ok
  end

  private

  def check_shared_secret
    head(403) unless params[:secret] == Events.shared_secret
  end
end
