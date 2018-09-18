class DeveloperPortal::ApiDocs::SessionsController < DeveloperPortal::LoginController
  before_action :store_location, :only => :new

  protected

  def store_location
    session[:return_to] = request.referer
  end
end
