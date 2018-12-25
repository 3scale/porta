require 'test_helper'

class ServiceBackendServiceTest < ActiveSupport::TestCase
  setup do
    @service = FactoryBot.create(:service)
    @service_update_backend_service = ServiceUpdateBackendService.new(service)
  end

  test 'load_service loads the service from Backend' do
    ThreeScale::Core::Service.expects(:load_by_id).with(service.id)
    service_update_backend_service.send(:load_service)
  end

  test 'load_service returns nil if it does not exist' do
    ThreeScale::Core::Service.expects(:load_by_id).with(service.id).returns(nil)
    assert_nil service_update_backend_service.send(:load_service)
  end

  test 'load_service! loads the service from Backend' do
    ThreeScale::Core::Service.expects(:load_by_id).with(service.id).returns(DummyServiceBackend.new)
    service_update_backend_service.send(:load_service!)
  end

  test 'load_service! raises ServiceNotFound if the Service is not in Backend' do
    ThreeScale::Core::Service.expects(:load_by_id).with(service.id).returns(nil)
    assert_raise(Backend::ServiceNotFound) { service_update_backend_service.send(:load_service!) }
  end

  test 'update_state! updates' do
    first_service_backend = DummyServiceBackend.new
    service_update_backend_service.expects(:load_service!).once.returns(first_service_backend)
    first_service_backend.expects(:activate)
    first_service_backend.expects(:save!)

    service_update_backend_service.update_state!(:activate)
  end

  private

  attr_reader :service, :service_update_backend_service

  class DummyServiceBackend
    def activate; end
    def save!; end
  end
end
