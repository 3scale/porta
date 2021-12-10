# frozen_string_literal: true

class Provider::Admin::ServiceDiscovery::ClusterServicesController < Provider::Admin::ServiceDiscovery::ClusterBaseController
  def index
    render json: cluster.discoverable_services(namespace: namespace_id).map(&:name)
                                                                       .to_json
  end

  def show
    cluster_service = cluster.find_discoverable_service_by(namespace: namespace_id, name: params.require(:id))
    render json: cluster_service.to_json
  rescue ::ServiceDiscovery::ClusterClient::ResourceNotFound => exception
    render_error exception.message, status: :not_found
  end

  private

  def namespace_id
    params.require(:namespace_id)
  end
end
