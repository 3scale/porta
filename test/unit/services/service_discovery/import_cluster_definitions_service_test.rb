# frozen_string_literal: true

require 'test_helper'

module ServiceDiscovery
  class ImportClusterDefinitionsServiceTest < ActiveSupport::TestCase
    include TestHelpers::ServiceDiscovery

    setup do
      stub_external_cluster_initialization!
      @account = FactoryGirl.create(:simple_provider)

      cluster_service_metadata = {
        name: 'fake-api',
        namespace: 'fake-project',
        selfLink: '/api/v1/namespaces/fake-project/services/fake-api',
        labels: { :'discovery.3scale.net' => 'true' },
        annotations: {
          :'discovery.3scale.net/scheme' => 'https',
          :'discovery.3scale.net/port' => '8443',
          :'discovery.3scale.net/path' => 'api'
        }
      }
      @fake_cluster_service = ServiceDiscovery::ClusterService.new cluster_service(metadata: cluster_service_metadata)
      @import_service = ImportClusterDefinitionsService.new
    end

    test 'create service async' do
      CreateServiceWorker.expects(:perform_async).with(@account.id, 'fake-project', 'fake-api')
      new_service = ImportClusterDefinitionsService.create_service(@account, cluster_namespace: 'fake-project',
                                                                             cluster_service_name: 'fake-api')
      refute new_service.persisted?
      assert_equal 'fake-api', new_service.name
    end

    test 'create service' do
      ServiceDiscovery::ClusterClient.any_instance.stubs(:find_discoverable_service_by).returns(@fake_cluster_service)

      assert_difference @account.services.method(:count) do
        Service.any_instance.expects(:import_cluster_definitions).with(@fake_cluster_service)
        @import_service.create_service(@account, cluster_namespace: 'fake-project', cluster_service_name: 'fake-api')
      end
    end

    test 'refresh service async' do
      service = FactoryGirl.create(:service, account: @account,
                                             name: 'fake-api',
                                             system_name: 'fake-project-fake-api')

      service.stubs(discovered?: true)
      RefreshServiceWorker.expects(:perform_async).with(service.id)
      ImportClusterDefinitionsService.refresh_service(service)
    end

    test 'refresh service' do
      service = FactoryGirl.create(:service, account: @account,
                                             name: 'fake-api',
                                             system_name: 'fake-project-fake-api',
                                             kubernetes_service_link: '/api/v1/namespaces/fake-project/services/fake-api')

      ServiceDiscovery::ClusterClient.any_instance.stubs(:find_discoverable_service_by).returns(@fake_cluster_service)

      Service.any_instance.expects(:import_cluster_definitions).with(@fake_cluster_service)
      @import_service.refresh_service(service)
    end
  end
end
