# frozen_string_literal: true

class Admin::Api::ServiceDiscovery::ClusterProjectsController < Admin::Api::ServiceDiscovery::ClusterBaseController
  representer ::ServiceDiscovery::ClusterProject

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/service_discovery/projects.xml"
  ##~ e.responseClass = "List[cluster_projects]"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "Service Discovery: Cluster Projects List"
  ##~ op.description = "Returns the list of all projects with discoverable services within the underlying Openshift cluster."
  ##~ op.group       = "service_discovery"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def index
    respond_with(cluster.projects_with_discoverables)
  end
end
