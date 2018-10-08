# frozen_string_literal: true

class Provider::Admin::ServiceDiscovery::ClusterServicesController < Provider::Admin::ServiceDiscovery::ClusterBaseController
  def index
    render json: { services: cluster.discoverable_services(namespace: params.require(:namespace_id)).map(&:to_json) }
  end

  def show
    cluster_service = cluster.find_discoverable_service_by(namespace: params.require(:namespace_id), name: params[:id])
    render json: cluster_service.to_json
  rescue ::ServiceDiscovery::ClusterClient::ResourceNotFound => exception
    render_error exception.message, status: :not_found
  end
end
