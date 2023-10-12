require 'test_helper'

class PublishZyncEventSubscriberTest < ActiveSupport::TestCase
  def setup
    @subscriber = PublishZyncEventSubscriber.new
  end

  test 'publish Zync Event for OIDC auth' do
    service = FactoryBot.create(:simple_service, backend_version: 'oauth')
    application = FactoryBot.create(:simple_cinstance, service: service, tenant_id: 1)
    event = Applications::ApplicationCreatedEvent.create(application, nil)
    assert @subscriber.call(event)
  end

  test 'do not publish Zync Event for non-OIDC auth' do
    service = FactoryBot.create(:simple_service)
    application = FactoryBot.create(:simple_cinstance, service: service, tenant_id: 1)
    event = Applications::ApplicationCreatedEvent.create(application, nil)
    assert_nil @subscriber.call(event)
  end

  class DomainEventsTest < ActiveSupport::TestCase
    setup do
      @subscriber = PublishZyncEventSubscriber.new
      ThreeScale.config.stubs(onpremises: true)
    end

    attr_reader :subscriber

    test 'proxy domains event' do
      proxy = FactoryBot.build_stubbed(:proxy)
      event = Domains::ProxyDomainsChangedEvent.create proxy
      assert subscriber.call(event)
    end

    test 'provider domains event' do
      provider = FactoryBot.build_stubbed(:simple_provider)
      event = Domains::ProviderDomainsChangedEvent.create provider
      assert subscriber.call(event)
    end
  end

  class NotOnpremDomainEventsTest < ActiveSupport::TestCase
    setup do
      @subscriber = PublishZyncEventSubscriber.new
      ThreeScale.config.stubs(onpremises: false)
    end

    attr_reader :subscriber

    test 'proxy domains event' do
      proxy = FactoryBot.build_stubbed(:proxy)
      event = Domains::ProxyDomainsChangedEvent.create proxy
      refute subscriber.call(event)
    end

    test 'provider domains event' do
      provider = FactoryBot.build_stubbed(:simple_provider)
      event = Domains::ProviderDomainsChangedEvent.create provider
      refute subscriber.call(event)
    end
  end
end
