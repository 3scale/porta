# frozen_string_literal: true

require 'test_helper'

class Admin::API::ServiceDiscovery::ClusterServicesControllerTest < ActionDispatch::IntegrationTest
  include TestHelpers::ServiceDiscovery

  def setup
    provider = FactoryGirl.create(:provider_account)
    login! provider
    stub_external_cluster_initialization!
    @format = :xml
  end

  test '#index' do
    ::ServiceDiscovery::ClusterClient.any_instance.stubs(get_services: [
      cluster_service(metadata: { name: 'my-api-staging',    uid: '220151f0-1918-4eca-808a-d4d07cea4b16', namespace: 'my-namespace' }),
      cluster_service(metadata: { name: 'my-api-production', uid: '97a926db-e104-44ac-a5dd-43a0cf5ec686', namespace: 'my-namespace' })
    ])

    get admin_api_service_discovery_namespace_services_path(namespace_id: 'my-namespace', format: @format)
  end

  test '#show' do
    discoverable_cluster_service = cluster_service(
      metadata: {
        name: 'my-api-staging',
        uid: '220151f0-1918-4eca-808a-d4d07cea4b16',
        namespace: 'my-namespace',
        annotations: {
          :'api.service.kubernetes.io/description-path' => 'camel-rest-sql/api-doc',
          :'api.service.kubernetes.io/path' => 'camel-rest-sql',
          :'api.service.kubernetes.io/protocol' => 'REST',
          :'api.service.kubernetes.io/scheme' => 'http',
          :'api.service.kubernetes.io/description-language' => 'SwaggerJSON'
        }
      }
    )

    ::ServiceDiscovery::ClusterClient.any_instance.expects(:get_service)
                                                  .with('my-api-staging', 'my-namespace')
                                                  .returns(discoverable_cluster_service)

    get admin_api_service_discovery_namespace_service_path(namespace_id: 'my-namespace', id: 'my-api-staging', format: @format)
  end

  test '#show not found' do
    non_discoverable_cluster_service = cluster_service(
      metadata: {
        name: 'my-api-staging',
        uid: '220151f0-1918-4eca-808a-d4d07cea4b16',
        namespace: 'my-namespace'
      }
    )

    ::ServiceDiscovery::ClusterClient.any_instance.expects(:get_service)
                                                  .with('my-api-staging', 'my-namespace')
                                                  .returns(non_discoverable_cluster_service)

    get admin_api_service_discovery_namespace_service_path(namespace_id: 'my-namespace', id: 'my-api-staging', format: @format)
    assert_response :not_found
  end

  class JSON < Admin::API::ServiceDiscovery::ClusterServicesControllerTest
    def setup
      provider = FactoryGirl.create(:provider_account)
      login! provider
      stub_external_cluster_initialization!
      @format = :json
    end
  end
end
