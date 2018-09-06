# frozen_string_literal: true

require 'test_helper'

class Admin::API::ServiceDiscovery::ClusterNamespacesControllerTest < ActionDispatch::IntegrationTest
  include TestHelpers::ServiceDiscovery

  def setup
    provider = FactoryGirl.create(:provider_account)
    login! provider
    stub_external_cluster_initialization!
    @format = :xml
  end

  test '#index' do
    ::ServiceDiscovery::ClusterClient.any_instance.stubs(get_namespaces: [
      cluster_namespace(metadata: { name: 'namespace-1', uid: '246f96b6-89cc-11e8-b1c9-06694f191946' }),
      cluster_namespace(metadata: { name: 'namespace-2', uid: 'b8ceb6b6-dfaf-48a5-ba55-cc7bd898cc26' }),
      cluster_namespace(metadata: { name: 'namespace-3', uid: 'b60a2fea-4e23-4df4-b04d-c663ecb9c473' })
    ])

    ::ServiceDiscovery::ClusterClient.any_instance.stubs(get_services: [
      cluster_service(metadata: { name: 'my-api-staging',    uid: '220151f0-1918-4eca-808a-d4d07cea4b16', namespace: 'namespace-1' }),
      cluster_service(metadata: { name: 'my-api-production', uid: '97a926db-e104-44ac-a5dd-43a0cf5ec686', namespace: 'namespace-1' })
    ])

    get admin_api_service_discovery_namespaces_path(format: @format)
  end

  class JSON < Admin::API::ServiceDiscovery::ClusterNamespacesControllerTest
    def setup
      provider = FactoryGirl.create(:provider_account)
      login! provider
      stub_external_cluster_initialization!
      @format = :json
    end
  end
end
