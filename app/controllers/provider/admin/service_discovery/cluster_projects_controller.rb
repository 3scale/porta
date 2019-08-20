# frozen_string_literal: true

class Provider::Admin::ServiceDiscovery::ClusterProjectsController < Provider::Admin::ServiceDiscovery::ClusterBaseController
  def index
    render json: cluster.projects_with_discoverables.map(&:name)
                                                    .to_json
  end
end
