class Provider::Admin::Dashboard::Service::BaseController < Provider::Admin::Dashboard::WidgetController

  protected

  helper_method :service

  def service
    @_service ||= current_user.accessible_services.find(params[:service_id])

    authorize! :show, @_service

    @_service
  end
end
