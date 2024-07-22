# frozen_string_literal: true

class Api::ErrorsController < Api::BaseController
  helper_method :presenter
  attr_reader :presenter

  before_action :find_service

  activate_menu :serviceadmin, :monitoring, :errors

  def index
    errors = errors_service.list(@service.id, pagination_params)
    @presenter = Api::ErrorsIndexPresenter.new(errors: errors, service: @service)
  end

  def purge
    authorize! :update, @service

    errors_service.delete_all(@service.id)

    flash[:notice] = t('.success')
    redirect_to admin_service_errors_path(@service)
  end

  private

  def pagination_params
    params.permit(:page, :per_page).to_h.symbolize_keys
  end

  def errors_service
    @errors_service ||= IntegrationErrorsService.new
  end
end
