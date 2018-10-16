# frozen_string_literal: true

require 'test_helper'

module ServiceDiscovery
  class ImportClusterDefinitionsServiceTest < ActiveSupport::TestCase
    include TestHelpers::ServiceDiscovery

    class AsyncMethodsTest < ActiveSupport::TestCase
      setup do
        @account = FactoryGirl.create(:simple_provider)
        @service = FactoryGirl.create(:service, account: @account,
                                                name: 'fake-api',
                                                system_name: 'fake-project-fake-api',
                                                kubernetes_service_link: '/api/v1/namespaces/fake-project/services/fake-api')
      end

      test 'create service async' do
        CreateServiceWorker.expects(:perform_async).with(@account.id, 'fake-project', 'fake-api')
        new_service = ImportClusterDefinitionsService.create_service(@account, cluster_namespace: 'fake-project',
                                                                               cluster_service_name: 'fake-api')
        refute new_service.persisted?
        assert_equal 'fake-api', new_service.name
      end

      test 'refresh service async' do
        RefreshServiceWorker.expects(:perform_async).with(@service.id)
        ImportClusterDefinitionsService.refresh_service(@service)
      end
    end

    setup do
      stub_external_cluster_initialization!
      @account = FactoryGirl.create(:simple_provider)
      @service = FactoryGirl.create(:service, account: @account,
                                              name: 'fake-api',
                                              system_name: 'fake-project-fake-api',
                                              kubernetes_service_link: '/api/v1/namespaces/fake-project/services/fake-api')
      FactoryGirl.create(:proxy, service: @service, api_backend: 'http://api.example.net:80')

      @cluster_service = ServiceDiscovery::ClusterService.new raw_cluster_service_resource
      @cluster_service.stubs(specification: mock_cluster_service_spec)

      @import_service = ImportClusterDefinitionsService.new
    end

    test 'create service' do
      cluster_service = ServiceDiscovery::ClusterService.new raw_cluster_service_resource(name: 'new-fake-api')
      cluster_service.stubs(specification: mock_cluster_service_spec)
      @import_service.cluster.stubs(:find_discoverable_service_by).returns(cluster_service)
      assert_difference @account.services.method(:count) do
        Proxy.any_instance.expects(:save_and_deploy).with(api_backend: cluster_service.endpoint).returns(true)
        @import_service.create_service(@account, cluster_namespace: 'fake-project', cluster_service_name: 'new-fake-api')
      end
    end

    test 'refresh service' do
      @import_service.cluster.stubs(:find_discoverable_service_by).returns(@cluster_service)
      @service.proxy.expects(:save_and_deploy).with(api_backend: @cluster_service.endpoint).returns(true)
      @import_service.refresh_service(@service)
    end

    test 'import cluster definitions' do
      @import_service.expects(:import_cluster_service_endpoint_to).with(@service)
      @import_service.expects(:import_cluster_active_docs_to).with(@service)
      @import_service.send(:import_cluster_definitions_to, @service)
    end

    test 'import cluster service endpoint' do
      @import_service.stubs(cluster_service: @cluster_service)

      assert_equal 'http://api.example.net:80', @service.proxy.api_backend
      @import_service.send(:import_cluster_service_endpoint_to, @service)
      assert @service.proxy.valid?
      assert_equal 'https://fake-api.fake-project.svc.cluster.local:8443/api', @service.proxy.api_backend
    end

    test 'only import endpoint when it changes' do
      @import_service.stubs(cluster_service: @cluster_service)

      @service.proxy.expects(:save_and_deploy).never
      @cluster_service.stubs(endpoint: 'http://api.example.net:80')
      @import_service.send(:import_cluster_service_endpoint_to, @service)

      @service.proxy.expects(:save_and_deploy).with(api_backend: 'http://my-new-endpoint').returns(true)
      @cluster_service.stubs(endpoint: 'http://my-new-endpoint')
      @import_service.send(:import_cluster_service_endpoint_to, @service)
    end

    test 'unsupported backend base path' do
      @import_service.stubs(cluster_service: @cluster_service)

      @account.stubs(:provider_can_use?).with(:apicast_v1).returns(true)
      @account.stubs(:provider_can_use?).with(:apicast_v2).returns(true)
      @account.stubs(:provider_can_use?).with(:proxy_private_base_path).returns(false)

      System::ErrorReporting.expects(:report_error).with(responds_with(:message, 'Could not save API backend URL'), any_parameters)
      @import_service.send(:import_cluster_service_endpoint_to, @service)
      refute @service.proxy.valid?
      assert_equal 'http://api.example.net:80', @service.proxy.reload.api_backend
    end

    test 'import api_doc' do
      @import_service.stubs(cluster_service: @cluster_service)

      assert_difference @service.api_docs_services.method(:count) do
        @import_service.send(:import_cluster_active_docs_to, @service)

        discovered_api_docs_service = @service.discovered_api_docs_service
        assert discovered_api_docs_service.discovered
        assert_equal '{ "swagger" : "fake-swagger" }', discovered_api_docs_service.body
      end
    end

    test 'refreshes existing discovered api_docs_service' do
      @import_service.stubs(cluster_service: @cluster_service)

      discovered_api_docs_service = FactoryGirl.create(:api_docs_service, account: @account, service: @service, discovered: true)

      assert_no_difference @service.api_docs_services.method(:count) do
        @import_service.send(:import_cluster_active_docs_to, @service)

        discovered_api_docs_service = @service.discovered_api_docs_service
        assert_equal '{ "swagger" : "fake-swagger" }', discovered_api_docs_service.body
      end
    end

    test 'non-oas spec' do
      @import_service.stubs(cluster_service: @cluster_service)

      @cluster_service.stubs(specification: mock_cluster_service_spec(type: 'application/json'))

      assert_no_difference @account.api_docs_services.method(:count) do
        System::ErrorReporting.expects(:report_error).with(responds_with(:message, 'API specification type not supported'), any_parameters)
        @import_service.send(:import_cluster_active_docs_to, @service)
      end
    end

    test 'blank oas spec' do
      @import_service.stubs(cluster_service: @cluster_service)

      @cluster_service.stubs(specification: mock_cluster_service_spec(body: ''))

      assert_no_difference @account.api_docs_services.method(:count) do
        System::ErrorReporting.expects(:report_error).with(responds_with(:message, 'OAS specification is empty and cannot be imported'), any_parameters)
        @import_service.send(:import_cluster_active_docs_to, @service)
      end
    end

    test 'invalid api_doc record' do
      @import_service.stubs(cluster_service: @cluster_service)

      assert_no_difference @account.api_docs_services.method(:count) do
        api_doc = @import_service.send(:build_api_doc_service, @service)
        api_doc.stubs(valid?: false)
        @import_service.stubs(build_api_doc_service: api_doc)
        System::ErrorReporting.expects(:report_error).with(responds_with(:message, 'Could not create ActiveDocs'), any_parameters)
        @import_service.send(:import_cluster_active_docs_to, @service)
      end
    end

    private

    def cluster_service_metadata
      {
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
    end

    def raw_cluster_service_resource(metadata = {})
      cluster_service(metadata: cluster_service_metadata.deep_merge(metadata))
    end

    def mock_cluster_service_spec(options = {})
      spec = ClusterServiceSpecification.new('http://my-api.example.com/doc')
      spec.stubs({ fetch: true, body: '{ "swagger" : "fake-swagger" }', type: 'application/swagger+json' }.merge(options))
      spec
    end
  end
end
