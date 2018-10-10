# frozen_string_literal: true

require 'test_helper'

class ServiceCreationServiceTest < ActiveSupport::TestCase
  setup do
    @provider = FactoryGirl.create(:simple_provider)
  end

  test 'call' do
    assert_difference '@provider.services.count' do
      ServiceCreationService.call(@provider, name: 'my-api', system_name: 'my-api')
    end
  end

  test 'kubernetes_service_link' do
    service_creation = ServiceCreationService.call(@provider, name: 'my-api', system_name: 'my-api', kubernetes_service_link: '/api/v1/namespaces/fake-project/services/fake-api')
    assert_equal '/api/v1/namespaces/fake-project/services/fake-api', service_creation.service.kubernetes_service_link
  end

  test 'async' do
    service_attributes = { name: 'my-api', namespace: 'my-project' }
    assert_no_difference '@provider.services.count' do
      ServiceDiscovery::CreateServiceWorker.expects(:perform_async).with(@provider.id, *service_attributes.values_at(:namespace, :name))
      ServiceCreationService.call(@provider, service_attributes.merge(source: 'discover'))
    end
  end

  test 'source' do
    service_creation = ServiceCreationService.new(@provider, name: 'my-api', source: 'discover')
    service_creation.expects(:create_service).never
    service_creation.expects(:create_service_async).returns(true)
    service_creation.call

    service_creation = ServiceCreationService.new(@provider, name: 'my-api', source: 'manual')
    service_creation.expects(:create_service).returns(true)
    service_creation.expects(:create_service_async).never
    service_creation.call

    service_creation = ServiceCreationService.new(@provider, name: 'my-api')
    service_creation.expects(:create_service).returns(true)
    service_creation.expects(:create_service_async).never
    service_creation.call

    service_creation = ServiceCreationService.new(@provider, name: 'my-api', source: 'unsupported-value')
    service_creation.expects(:create_service).returns(true)
    service_creation.expects(:create_service_async).never
    service_creation.call
  end

  test 'discover?' do
    refute ServiceCreationService.new(@provider).discover?
    assert ServiceCreationService.new(@provider, source: 'discover').discover?
  end

  test 'success?' do
    service_creation = ServiceCreationService.new(@provider, name: 'my-api', system_name: 'my-api')
    Service.any_instance.stubs(save: true)
    service_creation.create_service
    assert service_creation.success?

    Service.any_instance.stubs(save: false)
    service_creation.create_service
    refute service_creation.success?

    service_creation_async = ServiceCreationService.new(@provider, name: 'my-api', namespace: 'my-project', source: 'discover')
    ServiceDiscovery::CreateServiceWorker.expects(:perform_async).returns(true)
    service_creation_async.create_service_async
    assert service_creation_async.success?

    ServiceDiscovery::CreateServiceWorker.expects(:perform_async).returns(false)
    service_creation_async.create_service_async
    assert service_creation_async.success?
  end
end
