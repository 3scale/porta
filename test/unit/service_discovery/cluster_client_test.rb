# frozen_string_literal: true

require 'test_helper'

module ServiceDiscovery
  class ClusterClientTest < ActiveSupport::TestCase
    include TestHelpers::ServiceDiscovery

    test 'fetches default cluster connection data from settings' do
      ThreeScale.config.expects(:service_discovery).returns({
        server_scheme: 'https',
        server_host: 'my-cluster.com',
        server_port: 8443,
        bearer_token: 'secret-token'
      })

      stub_external_cluster_initialization!

      ClusterClient.new
    end

    test 'namespaces' do
      cluster.stubs(get_namespaces: [
        cluster_namespace(metadata: { name: 'namespace-1', uid: '246f96b6-89cc-11e8-b1c9-06694f191946' }),
        cluster_namespace(metadata: { name: 'namespace-2', uid: 'b8ceb6b6-dfaf-48a5-ba55-cc7bd898cc26' }),
        cluster_namespace(metadata: { name: 'namespace-3', uid: 'b60a2fea-4e23-4df4-b04d-c663ecb9c473' })
      ])

      assert_equal %w[namespace-1 namespace-2 namespace-3], cluster.namespaces.map(&:name)
    end

    test 'find namespace by name' do
      cluster.expects(:get_namespace).with('my-namespace').returns(
        cluster_namespace(metadata: { name: 'my-namespace', uid: '246f96b6-89cc-11e8-b1c9-06694f191946' }),
      )

      assert_equal '246f96b6-89cc-11e8-b1c9-06694f191946', cluster.find_namespace_by(name: 'my-namespace').uid
    end

    test 'projects' do
      cluster.stubs(get_projects: [
        cluster_project(metadata: { name: 'project-1', uid: '65b984b8-57cc-4fb3-9ecc-e7c1f51e8355' }),
        cluster_project(metadata: { name: 'project-2', uid: '9649ec16-5500-4531-9f77-1bb2246cc672' }),
        cluster_project(metadata: { name: 'project-3', uid: '7032a178-9ecc-460e-986d-50a9969ce547' })
      ])

      assert_equal %w[project-1 project-2 project-3], cluster.projects.map(&:name)
    end

    test 'find project by name' do
      cluster.expects(:get_project).with('my-project').returns(
        cluster_namespace(metadata: { name: 'my-project', uid: '65b984b8-57cc-4fb3-9ecc-e7c1f51e8355' }),
      )

      assert_equal '65b984b8-57cc-4fb3-9ecc-e7c1f51e8355', cluster.find_project_by(name: 'my-project').uid
    end

    test 'services' do
      cluster.stubs(get_services: [
        cluster_service(metadata: { name: 'my-api-staging',    uid: '220151f0-1918-4eca-808a-d4d07cea4b16', namespace: 'my-namespace' }, spec: { ports: [{ protocol: 'TCP', port: 3000, targetPort: 8080 }] }),
        cluster_service(metadata: { name: 'my-api-production', uid: '97a926db-e104-44ac-a5dd-43a0cf5ec686', namespace: 'my-namespace' }, spec: { ports: [{ protocol: 'TCP', port: 3001, targetPort: 8080 }] })
      ])

      assert_equal %w[my-api-staging my-api-production], cluster.services(namespace: 'my-namespace').map(&:name)
    end

    test 'services in a given namespace' do
      cluster.expects(:get_services).with(namespace: 'my-namespace').returns([
        cluster_service(metadata: { name: 'my-api-staging',    uid: '220151f0-1918-4eca-808a-d4d07cea4b16', namespace: 'my-namespace' }, spec: { ports: [{ protocol: 'TCP', port: 3000, targetPort: 8080 }] }),
        cluster_service(metadata: { name: 'my-api-production', uid: '97a926db-e104-44ac-a5dd-43a0cf5ec686', namespace: 'my-namespace' }, spec: { ports: [{ protocol: 'TCP', port: 3001, targetPort: 8080 }] })
      ])
      cluster.expects(:get_services).with(namespace: 'other-namespace').returns([
        cluster_service(metadata: { name: 'my-other-api',      uid: 'b3ae7f5b-6188-4cc9-8fff-5fd4eff79056', namespace: 'other-namespace' }, spec: { ports: [{ protocol: 'TCP', port: 3000, targetPort: 8080 }] })
      ])

      assert_equal %w[my-api-staging my-api-production], cluster.services(namespace: 'my-namespace').map(&:name)
      assert_equal %w[my-other-api], cluster.services(namespace: 'other-namespace').map(&:name)
    end

    test 'discoverable services' do
      cluster.stubs(get_services: [
        cluster_service(metadata: { name: 'non-discoverable-api', uid: '220151f0-1918-4eca-808a-d4d07cea4b16', namespace: 'my-namespace' }),
        cluster_service(
          metadata: {
            name: 'discoverable-api',
            uid: '97a926db-e104-44ac-a5dd-43a0cf5ec686',
            namespace: 'my-namespace',
            labels: {
              :'discovery.3scale.net' => 'true',
            },
            annotations: {
              :'discovery.3scale.net/scheme' => 'http',
              :'discovery.3scale.net/port' => '8080',
              :'discovery.3scale.net/path' => 'camel-rest-sql',
              :'discovery.3scale.net/description-path' => 'camel-rest-sql/api-doc'
            }
          }
        )
      ])

      assert_equal %w[discoverable-api], cluster.discoverable_services(namespace: 'my-namespace').map(&:name)
    end

    test 'find service by name' do
      cluster.expects(:get_service).with('my-api-staging', 'my-namespace').returns(
        cluster_service(metadata: { name: 'my-api-staging', uid: 'b3ae7f5b-6188-4cc9-8fff-5fd4eff79056', namespace: 'my-namespace' })
      )

      assert_equal 'my-api-staging', cluster.find_service_by(name: 'my-api-staging', namespace: 'my-namespace').name
    end

    test 'find discoverable service by name' do
      discoverable_service = cluster_service(
        metadata: {
          name: 'my-api-staging',
          uid: 'b3ae7f5b-6188-4cc9-8fff-5fd4eff79056',
          namespace: 'my-namespace',
          labels: {
            :'discovery.3scale.net' => 'true',
          },
          annotations: {
            :'discovery.3scale.net/scheme' => 'http',
            :'discovery.3scale.net/port' => '8080',
            :'discovery.3scale.net/path' => 'camel-rest-sql',
            :'discovery.3scale.net/description-path' => 'camel-rest-sql/api-doc'
          }
        }
      )
      cluster.expects(:get_service).with('my-api-staging', 'my-namespace').returns(discoverable_service)

      assert_equal 'my-api-staging', cluster.find_discoverable_service_by(name: 'my-api-staging', namespace: 'my-namespace').name
    end

    test 'project with discoverables' do
      cluster.stubs(get_projects: [
        cluster_project(metadata: { name: 'project-1', uid: '65b984b8-57cc-4fb3-9ecc-e7c1f51e8355' }),
        cluster_project(metadata: { name: 'project-2', uid: '9649ec16-5500-4531-9f77-1bb2246cc672' })
      ])

      cluster.expects(:get_services).with(namespace: 'project-1', label_selector: 'discovery.3scale.net=true').returns([
        cluster_service(metadata: { name: 'non-discoverable-api-1', uid: '220151f0-1918-4eca-808a-d4d07cea4b16', namespace: 'project-1' } )
      ])

      cluster.expects(:get_services).with(namespace: 'project-2', label_selector: 'discovery.3scale.net=true').returns([
        cluster_service(metadata: { name: 'non-discoverable-api-2', uid: 'a608a921-d715-4192-9171-5306c476260a', namespace: 'project-2' } ),
        cluster_service(
          metadata: {
            name: 'discoverable-api',
            uid: '97a926db-e104-44ac-a5dd-43a0cf5ec686',
            namespace: 'project-2',
            labels: {
              :'discovery.3scale.net' => 'true',
            },
            annotations: {
              :'discovery.3scale.net/scheme' => 'http',
              :'discovery.3scale.net/port' => '8080',
              :'discovery.3scale.net/path' => 'camel-rest-sql',
              :'discovery.3scale.net/description-path' => 'camel-rest-sql/api-doc'
            }
          }
        )
      ])

      assert_equal %w[project-2], cluster.projects_with_discoverables.map(&:name)
    end

    test 'routes' do
      cluster.stubs(get_routes: [
        cluster_route(metadata: { name: 'my-api-staging-route',    uid: '220151f0-1918-4eca-808a-d4d07cea4b16', namespace: 'my-namespace' }, spec: { to: { kind: 'Service', name: 'my-api-staging' } }),
        cluster_route(metadata: { name: 'my-api-production-route', uid: '97a926db-e104-44ac-a5dd-43a0cf5ec686', namespace: 'my-namespace' }, spec: { to: { kind: 'Service', name: 'my-api-production' } })
      ])

      assert_equal %w[my-api-staging-route my-api-production-route], cluster.routes(namespace: 'my-namespace').map(&:name)
    end

    test 'find route by name' do
      cluster.expects(:get_route).with('my-api-staging-route', 'my-namespace').returns(
        cluster_route(metadata: { name: 'my-api-staging-route', uid: '220151f0-1918-4eca-808a-d4d07cea4b16', namespace: 'my-namespace' }, spec: { to: { kind: 'Service', name: 'my-api-staging' } }),
      )

      assert_equal '220151f0-1918-4eca-808a-d4d07cea4b16', cluster.find_route_by(name: 'my-api-staging-route', namespace: 'my-namespace').uid
    end

    test 'raises resource not found' do
      cluster.expects(:get_service).with('my-api-staging', 'my-namespace').returns(nil)

      assert_raises(ServiceDiscovery::ClusterClient::ResourceNotFound) do
        cluster.find_discoverable_service_by(namespace: 'my-namespace', name: 'my-api-staging').name
      end
    end

    test 'raises generic client exception' do
      exception = KubeException.new(123, 'generic error', mock)
      cluster.expects(:get_project).with('my-namespace').raises(exception)

      assert_raises(ServiceDiscovery::ClusterClient::ClusterClientError) do
        cluster.find_project_by(name: 'my-namespace')
      end
    end
  end
end
