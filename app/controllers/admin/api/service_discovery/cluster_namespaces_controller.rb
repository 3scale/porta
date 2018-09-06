# frozen_string_literal: true

class Admin::Api::ServiceDiscovery::ClusterNamespacesController < Admin::Api::ServiceDiscovery::ClusterBaseController
  representer ::ServiceDiscovery::ClusterNamespace

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/service_discovery/namespaces.xml"
  ##~ e.responseClass = "List[cluster_namespaces]"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "Service Discovery: Cluster Namespaces List"
  ##~ op.description = "Returns the list of all namespaces within the underlying Kubernetes/Openshift cluster. It requires cluster-level permission to view the namespaces"
  ##~ op.group       = "service_discovery"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def index
    respond_with(cluster.namespaces)
  end
end
