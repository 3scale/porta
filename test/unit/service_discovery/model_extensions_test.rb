# frozen_string_literal: true

require 'test_helper'

module ServiceDiscovery
  module ModelExtensions
    class ServiceTest < ActiveSupport::TestCase
      include TestHelpers::ServiceDiscovery

      setup do
        @provider = FactoryGirl.create(:simple_provider)
        @service = FactoryGirl.create(:service, account: @provider)

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
