# frozen_string_literal: true

class Admin::Api::ServiceDiscovery::ClusterServicesController < Admin::Api::ServiceDiscovery::ClusterBaseController
  representer ::ServiceDiscovery::ClusterService

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/service_discovery/namespaces/{namespace}/services.xml"
  ##~ e.responseClass = "List[cluster_services]"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "Service Discovery: Cluster Services List"
  ##~ op.description = "Returns the list of all discoverable services for a given namespace within the underlying Kubernetes/Openshift cluster."
  ##~ op.group       = "service_discovery"
  #
  ##~ op.parameters.add :dataType => "string", :required => true, :paramType => "path", :name => "namespace", :description => "Namespace of the service"
  ##~ op.parameters.add @parameter_access_token
  #
  def index
    respond_with(cluster.discoverable_services(namespace: params[:namespace_id]))
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/service_discovery/namespaces/{namespace}/services/{service_name}.xml"
  ##~ e.responseClass = "cluster_service"
  ##~
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "Service Discovery: Cluster Service Read"
  ##~ op.description = "Returns the details of a discoverable service of a given namespace within the underlying Kubernetes/Openshift cluster."
  ##~ op.group       = "service_discovery"
  #
  ##~ op.parameters.add :dataType => "string", :required => true, :paramType => "path", :name => "namespace", :description => "Namespace of the service"
  ##~ op.parameters.add :dataType => "string", :required => true, :paramType => "path", :name => "service_name", :description => "Name of the service"
  ##~ op.parameters.add @parameter_access_token
  #
  def show
    cluster_service = cluster.find_discoverable_service_by(namespace: params[:namespace_id], name: params[:id])
    respond_with(cluster_service)
  rescue ServiceDiscovery::ClusterClient::ResourceNotFound => exception
    render_error exception.message, status: :not_found
  end
end
