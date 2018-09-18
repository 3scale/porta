class Api::ErrorsController < FrontendController

  activate_menu :monitoring, :integration_errors

  def index
    services = if (service_id = params[:service_id])
      current_user.accessible_services.where(id: service_id)
               else
      current_user.accessible_services
               end

    @service_errors = services.map do |service|
      [service, errors_service.list(service.id, pagination_params)]
    end
  end

  def purge
    @service = current_user.accessible_services.find(params[:service_id])

    authorize! :update, @service

    errors_service.delete_all(@service.id)

    respond_to do |format|
      format.html do
        flash[:notice] = 'All errors were purged.'
        redirect_to(admin_errors_url)
      end

      format.js
    end
  end

  private

  def pagination_params
    params.permit(:page, :per_page).symbolize_keys
  end

  def errors_service
    @errors_service ||= IntegrationErrorsService.new
  end
end
