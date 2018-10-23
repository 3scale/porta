# frozen_string_literal: true

# All child controllers only respond to Ajax calls
class Provider::Admin::ServiceDiscovery::ClusterBaseController < Provider::Admin::BaseController
  respond_to :json
  before_action :find_cluster

  attr_reader :cluster

  protected

  def find_cluster
    @cluster ||= ::ServiceDiscovery::ClusterClient.new bearer_token: token_retriever.access_token
  end

  def token_retriever
    ServiceDiscovery::TokenRetriever.new(current_user)
  end
end
