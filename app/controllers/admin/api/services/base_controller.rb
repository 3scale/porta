class Admin::Api::Services::BaseController < Admin::Api::BaseController

  private

  def service
    @service ||= accessible_services.find(params[:service_id])
  end
end
