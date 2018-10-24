# frozen_string_literal: true

# All child controllers only respond to Ajax calls
class Provider::Admin::ServiceDiscovery::ClusterBaseController < Provider::Admin::BaseController
  respond_to :json
  include ServiceDiscovery::ControllerMethods
  before_action :find_cluster


end
