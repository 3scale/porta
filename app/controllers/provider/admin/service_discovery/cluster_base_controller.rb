# frozen_string_literal: true

class Provider::Admin::ServiceDiscovery::ClusterBaseController < Provider::Admin::BaseController
  respond_to :json
  before_action :find_cluster

  attr_reader :cluster

  protected

  def find_cluster
    @cluster ||= ::ServiceDiscovery::ClusterClient.new
  end
end
