# this is the base controller for all apis hanging from service
#TODO is this a good name?
class Admin::Api::ServiceBaseController < Admin::Api::BaseController

  protected

  def service
    @service ||= accessible_services.find(params[:service_id])
  end

  def scope
    @scope ||= params[:service_id] ? service : current_account
  end

  def flat_params
    super.except(:service_id)
  end
end
