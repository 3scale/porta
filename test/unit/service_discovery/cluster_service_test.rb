# frozen_string_literal: true

require 'test_helper'

module ServiceDiscovery
  class ClusterServiceTest < ActiveSupport::TestCase
    include TestHelpers::ServiceDiscovery

    setup do
      @cluster_service_data = {
        metadata: {
          name: 'fake-api',
          namespace: 'fake-project',
          selfLink: '/api/v1/namespaces/fake-project/services/fake-api',
          uid: 'bc6ad9cd-99f2-43a3-91b2-93b7038b0454',
          resourceVersion: '40582387',
          creationTimestamp: '2018-07-17T14:18:55Z',
          labels: {
            :'discovery.3scale.net' => 'true',
            app: 'fake-api',
            template: 'fake-template'
          },
          annotations: {
            :'discovery.3scale.net/scheme' => 'http',
            :'discovery.3scale.net/port' => '8081',
            :'discovery.3scale.net/path' => 'api',
            :'discovery.3scale.net/description-path' => 'api/doc'
          }
        },
        spec: {
          ports: [{ name: 'http', protocol: 'TCP', port: 8080, targetPort: 8081 }],
          selector: { app: 'fake-api' },
          clusterIP: '122.50.171.300',
          type: 'ClusterIP',
          sessionAffinity: 'None'
        },
        status: { loadBalancer: {} }
      }
      @cluster_service = ClusterService.new(cluster_service(@cluster_service_data))
    end

    test 'valid' do
      assert @cluster_service.valid?

      invalid_cluster_service_data = @cluster_service_data.dup
      invalid_cluster_service_data[:metadata][:annotations].delete(:'discovery.3scale.net/scheme')
      invalid_cluster_service = ClusterService.new(cluster_service(invalid_cluster_service_data))
      refute invalid_cluster_service.valid?

      invalid_cluster_service_data = @cluster_service_data.dup
      invalid_cluster_service_data[:metadata][:annotations].delete(:'discovery.3scale.net/port')
      invalid_cluster_service = ClusterService.new(cluster_service(invalid_cluster_service_data))
      refute invalid_cluster_service.valid?
    end

    test 'discoverable?' do
      assert @cluster_service.discoverable?

      undiscoverable_cluster_service_data = @cluster_service_data.dup
      undiscoverable_cluster_service_data[:metadata][:labels].delete(:'discovery.3scale.net')
      undiscoverable_cluster_service = ClusterService.new(cluster_service(undiscoverable_cluster_service_data))
      refute undiscoverable_cluster_service.discoverable?
    end

    test 'scheme' do
      assert_equal 'http', @cluster_service.scheme
    end

    test 'host' do
      assert_equal 'fake-api.fake-project.svc.cluster.local', @cluster_service.host
    end

    test 'port' do
      assert_equal 8081, @cluster_service.port.to_i
    end

    test 'host and port' do
      assert_equal 'fake-api.fake-project.svc.cluster.local:8081', @cluster_service.host_and_port
    end

    test 'root' do
      assert_equal 'http://fake-api.fake-project.svc.cluster.local:8081', @cluster_service.root
    end

    test 'path' do
      assert_equal 'api', @cluster_service.path
    end

    test 'endpoint' do
      assert_equal 'http://fake-api.fake-project.svc.cluster.local:8081/api', @cluster_service.endpoint

      @cluster_service.stubs(path: '')
      assert_equal 'http://fake-api.fake-project.svc.cluster.local:8081', @cluster_service.endpoint

      @cluster_service.stubs(path: '/')
      assert_equal 'http://fake-api.fake-project.svc.cluster.local:8081/', @cluster_service.endpoint

      @cluster_service.stubs(path: nil)
      assert_equal 'http://fake-api.fake-project.svc.cluster.local:8081', @cluster_service.endpoint
    end

    test 'description path' do
      assert_equal 'api/doc', @cluster_service.description_path
    end

    test 'specification url' do
      assert_equal 'http://fake-api.fake-project.svc.cluster.local:8081/api/doc', @cluster_service.specification_url

      cluster_service_data = @cluster_service_data.deep_merge(metadata: { annotations: { :'discovery.3scale.net/description-path' => 'https://example.com/api-doc.json' } })
      cluster_service = ClusterService.new(cluster_service(cluster_service_data))
      assert_equal 'https://example.com/api-doc.json', cluster_service.specification_url
    end

    private

    def multiple_ports
      { ports: [
        { name: 'https', protocol: 'TCP', port: 443, targetPort: 8443 },
        { name: 'http', protocol: 'TCP', port: 80, targetPort: 8080 }
      ]}
    end
  end
end
