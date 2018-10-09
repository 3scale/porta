# frozen_string_literal: true

require 'test_helper'

module ServiceDiscovery
  module ModelExtensions
    class ServiceTest < ActiveSupport::TestCase
      include TestHelpers::ServiceDiscovery

      setup do
        @provider = FactoryGirl.create(:simple_provider)
        @service = FactoryGirl.create(:service, account: @provider)
        FactoryGirl.create(:proxy, service: @service, api_backend: 'http://api.example.net:80')

        cluster_service_metadata = {
          name: 'fake-api',
          namespace: 'fake-project',
          labels: { :'discovery.3scale.net' => 'true' },
          annotations: {
            :'discovery.3scale.net/scheme' => 'https',
            :'discovery.3scale.net/port' => '8443',
            :'discovery.3scale.net/path' => 'api',
            :'discovery.3scale.net/description-path' => 'api/doc'
          }
        }
        @cluster_service = ServiceDiscovery::ClusterService.new cluster_service(metadata: cluster_service_metadata)
      end

      test 'import cluster service endpoint' do
        assert_equal 'http://api.example.net:80', @service.proxy.api_backend
        @service.import_cluster_service_endpoint(@cluster_service)
        assert @service.proxy.valid?
        assert_equal 'https://fake-api.fake-project.svc.cluster.local:8443/api', @service.proxy.api_backend
      end

      test 'import api_doc' do
        @cluster_service.stubs(fetch_specification: true,
                               specification: '{ "swagger" : "fake-swagger" }',
                               specification_type: 'application/swagger+json')

        assert_difference @service.api_docs_services.method(:count) do
          @service.import_cluster_active_docs(@cluster_service)
        end
      end

      test 'unsupported backend base path' do
        @provider.stubs(:provider_can_use?).with(:apicast_v1).returns(true)
        @provider.stubs(:provider_can_use?).with(:apicast_v2).returns(true)
        @provider.stubs(:provider_can_use?).with(:proxy_private_base_path).returns(false)

        System::ErrorReporting.expects(:report_error).with(responds_with(:message, 'Could not save API backend URL'), any_parameters)
        @service.import_cluster_service_endpoint(@cluster_service)
        refute @service.proxy.valid?
        assert_equal 'http://api.example.net:80', @service.proxy.reload.api_backend
      end

      test 'non-oas spec' do
        @cluster_service.stubs(fetch_specification: true,
                               specification: '{ "swagger" : "fake-swagger" }',
                               specification_type: 'application/json')

        assert_no_difference @provider.api_docs_services do
          System::ErrorReporting.expects(:report_error).with(responds_with(:message, 'API specification type not supported'), any_parameters)
          @service.import_cluster_active_docs(@cluster_service)
        end
      end

      test 'blank oas spec' do
        @cluster_service.stubs(fetch_specification: true,
                               specification: '',
                               specification_type: 'application/swagger+json')

        assert_no_difference @provider.api_docs_services do
          System::ErrorReporting.expects(:report_error).with(responds_with(:message, 'OAS specification is empty and cannot be imported'), any_parameters)
          @service.import_cluster_active_docs(@cluster_service)
        end
      end

      test 'invalid api_doc record' do
        @cluster_service.stubs(fetch_specification: true,
                               specification: '{ "swagger" : "fake-swagger" }',
                               specification_type: 'application/swagger+json')

        assert_no_difference @provider.api_docs_services do
          ApiDocs::Service.any_instance.stubs(valid?: false)
          System::ErrorReporting.expects(:report_error).with(responds_with(:message, 'Could not create ActiveDocs'), any_parameters)
          @service.import_cluster_active_docs(@cluster_service)
        end
      end
    end
  end
end
