# TODO: those controllers are service specific and routed elsewhere -
# move them to the right namespace
#

class Stats::ServiceBaseController < Stats::BaseController
  include ApiAuthentication::ByAccessToken
  self.access_token_scopes = :stats

  before_action :authorize_monitoring
  before_action :find_service

  activate_menu :serviceadmin, :monitoring

  sublayout :stats

  protected

  # TODO: ensure provider domain
  def authorize_monitoring
    authorize! :manage, :monitoring
  end

  def find_service
    @service = collection.find(params[:service_id])
    authorize! :show, @service
  end

  def collection
    (current_user || current_account).accessible_services
  end
end
