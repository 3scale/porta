module TestHelpers
  module ServiceDiscovery

    protected

    def stub_external_cluster_initialization!
      Kubeclient::Client.stubs(initialize_client: true)
      Kubeclient::Client.any_instance.stubs(discover: true)
    end

    def cluster
      @cluster ||= begin
        stub_external_cluster_initialization!
        ::ServiceDiscovery::ClusterClient.new
      end
    end

    def cluster_resource(entity_type, data)
      klass = Kubeclient::ClientMixin.resource_class(Kubeclient, entity_type)
      cluster.new_entity(data, klass)
    end

    def cluster_namespace(data = {})
      cluster_resource('Namespace', cluster_namespace_data(data))
    end

    def cluster_namespace_data(data = {})
      {
        metadata: {
          name: 'fake-project',
          selfLink: '/api/v1/namespaces/fake-project',
          uid: '818ea53a-14f6-4f80-91f7-6a4b3d4bcd64',
          resourceVersion: '40582061',
          creationTimestamp: '2018-07-17T14:17:31Z',
          annotations: {
            :"openshift.io/description" => 'My Fake Project',
            :"openshift.io/display-name" => 'Fake Project',
            :"openshift.io/requester" => 'John Doe',
          }
        },
        spec: { finalizers: ['openshift.io/origin', 'kubernetes'] },
        status: { phase: 'Active' }
      }.deep_merge(data)
    end

    def cluster_project(data = {})
      cluster_resource('Project', cluster_project_data(data))
    end

    alias cluster_project_data cluster_namespace_data

    def cluster_service(data = {})
      cluster_resource('Service', cluster_service_data(data))
    end

    def cluster_service_data(data = {})
      {
        metadata: {
          name: 'fake-api',
          namespace: 'fake-project',
          selfLink: '/api/v1/namespaces/fake-project/services/fake-api',
          uid: 'bc6ad9cd-99f2-43a3-91b2-93b7038b0454',
          resourceVersion: '40582387',
          creationTimestamp: '2018-07-17T14:18:55Z',
          labels: { app: 'fake-api', template: 'fake-template' },
          annotations: { :"prometheus.io/path" => '/system/metrics', :"prometheus.io/scrape" => 'true'}
        },
        spec: {
          ports: [{ name: 'http', protocol: 'TCP', port: 8080, targetPort: 8080 }],
          selector: { app: 'fake-api' },
          clusterIP: '122.50.171.300',
          type: 'ClusterIP',
          sessionAffinity: 'None'
        },
        status: { loadBalancer: {} }
      }.deep_merge(data)
    end

    def cluster_route(data = {})
      cluster_resource('Route', cluster_route_data(data))
    end

    def cluster_route_data(data = {})
      {
        metadata: {
          name: 'fake-api-route',
          namespace: 'fake-project',
          selfLink: '/api/v1/namespaces/fake-project/services/fake-api',
          uid: 'bc6ad9cd-99f2-43a3-91b2-93b7038b0454',
          resourceVersion: '40582387',
          creationTimestamp: '2018-07-17T14:18:55Z',
          labels: { app: 'fake-api', template: 'fake-template' },
          ownerReferences: [
            {
              apiVersion: 'template.openshift.io/v1',
              blockOwnerDeletion: true,
              kind: 'TemplateInstance',
              name: '9eb4fa70-da5b-4dc4-971a-d0f1d2ca4836',
              uid: '2592fdef-b5e2-11e8-bb60-06694f191946'
            }
          ],
          annotations: { :"openshift.io/host.generated" => 'true'}
        },
        spec: {
          host: 'fake-api-route.my-domain.test',
          to: { kind: 'Service', name: 'fake-api', weight: 100 },
        },
        status: { routerName: 'router' }
      }.deep_merge(data)
    end
  end
end
