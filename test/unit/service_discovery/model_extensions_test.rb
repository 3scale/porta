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

      test 'discovered?' do
        refute @service.discovered?
        @service.update_attribute(:kubernetes_service_link, '/api/v1/namespaces/fake-project/services/fake-api')
        assert @service.reload.discovered?
      end

      test 'import cluster definitions' do
        @service.expects(:import_cluster_service_endpoint).with(@cluster_service)
        @service.expects(:import_cluster_active_docs).with(@cluster_service)
        @service.import_cluster_definitions(@cluster_service)
      end

      test 'import cluster service endpoint' do
        assert_equal 'http://api.example.net:80', @service.proxy.api_backend
        @service.import_cluster_service_endpoint(@cluster_service)
        assert @service.proxy.valid?
        assert_equal 'https://fake-api.fake-project.svc.cluster.local:8443/api', @service.proxy.api_backend
      end

      test 'only import endpoint when it changes' do
        @service.proxy.expects(:save_and_deploy).never
        @service.import_cluster_service_endpoint(mock(endpoint: 'http://api.example.net:80'))

        @service.proxy.expects(:save_and_deploy).with(api_backend: 'http://my-new-endpoint').returns(true)
        @service.import_cluster_service_endpoint(mock(endpoint: 'http://my-new-endpoint'))
      end

      test 'import api_doc' do
        stub_cluster_service_spec(@cluster_service)

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
        stub_cluster_service_spec(@cluster_service, type: 'application/json')

        assert_no_difference @provider.api_docs_services.method(:count) do
          System::ErrorReporting.expects(:report_error).with(responds_with(:message, 'API specification type not supported'), any_parameters)
          @service.import_cluster_active_docs(@cluster_service)
        end
      end

      test 'blank oas spec' do
        stub_cluster_service_spec(@cluster_service, body: '')

        assert_no_difference @provider.api_docs_services.method(:count) do
          System::ErrorReporting.expects(:report_error).with(responds_with(:message, 'OAS specification is empty and cannot be imported'), any_parameters)
          @service.import_cluster_active_docs(@cluster_service)
        end
      end

      test 'invalid api_doc record' do
        stub_cluster_service_spec(@cluster_service)

        assert_no_difference @provider.api_docs_services.method(:count) do
          ::ApiDocs::Service.any_instance.stubs(valid?: false)
          System::ErrorReporting.expects(:report_error).with(responds_with(:message, 'Could not create ActiveDocs'), any_parameters)
          @service.import_cluster_active_docs(@cluster_service)
        end
      end

      test 'discovered api_docs_service' do
        stub_cluster_service_spec(@cluster_service)

        assert_difference @service.api_docs_services.method(:count) do
          @service.import_cluster_active_docs(@cluster_service)

          discovered_api_docs_service = @service.discovered_api_docs_service
          assert discovered_api_docs_service.discovered
          assert_equal '{ "swagger" : "fake-swagger" }', discovered_api_docs_service.body
        end
      end

      test 'refreshes discovered api_docs_service' do
        stub_cluster_service_spec(@cluster_service)

        discovered_api_docs_service = FactoryGirl.create(:api_docs_service, account: @provider, service: @service, discovered: true)

        assert_no_difference @service.api_docs_services.method(:count) do
          @service.import_cluster_active_docs(@cluster_service)

          discovered_api_docs_service = @service.discovered_api_docs_service
          assert_equal '{ "swagger" : "fake-swagger" }', discovered_api_docs_service.body
        end
      end

      private

      def stub_cluster_service_spec(cluster_service, options = {})
        spec = ClusterServiceSpecification.new(cluster_service.specification_url)
        spec.stubs({ fetch: true, body: '{ "swagger" : "fake-swagger" }', type: 'application/swagger+json' }.merge(options))
        cluster_service.stubs(specification: spec)
      end
    end

    class ApiDocs::ServiceTest < ActiveSupport::TestCase
      test 'discovered is readonly' do
        api_doc = FactoryGirl.create(:api_docs_service, discovered: true)

        api_doc.update! discovered: false
        assert api_doc.reload.discovered
      end

      test 'discovered scope' do
        api_docs =  FactoryGirl.create_list(:api_docs_service, 2, discovered: true)
        api_docs += FactoryGirl.create_list(:api_docs_service, 3, discovered: false)

        assert_same_elements api_docs[0..1].map(&:id), ::ApiDocs::Service.discovered.pluck(:id)
      end

      test 'only one discovered by service' do
        service = FactoryGirl.create(:simple_service)

        api_doc = FactoryGirl.build(:api_docs_service, service: service, account: service.account)
        assert api_doc.valid?

        api_doc = FactoryGirl.build(:api_docs_service, service: service, account: service.account, discovered: true)
        assert api_doc.valid?

        FactoryGirl.create(:api_docs_service, service: service, account: service.account, discovered: true)
        api_doc = FactoryGirl.build(:api_docs_service, service: service, account: service.account, discovered: true)
        refute api_doc.valid?
        assert api_doc.errors[:discovered].present?

        api_doc.discovered = false
        assert api_doc.valid?
      end
    end
  end
end
