# frozen_string_literal: true

class Admin::Api::ServiceDiscovery::ClusterBaseController < Admin::Api::BaseController
  respond_to :json
  before_action :find_cluster

  attr_reader :cluster

  def stale?(*)
    true # FIXME
  end

  protected

  def find_cluster
    @cluster ||= ServiceDiscovery::ClusterClient.new
  end
end
