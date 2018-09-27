class Api::ErrorsController < Api::BaseController

  before_action :find_service

  activate_menu :monitoring, :analytics
  sublayout 'stats'

  def index
    @errors = errors_service.list(@service.id, pagination_params)
  end

  def purge
    authorize! :update, @service

    errors_service.delete_all(@service.id)

    respond_to do |format|
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
