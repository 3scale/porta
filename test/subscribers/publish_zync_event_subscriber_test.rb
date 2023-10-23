# frozen_string_literal: true

require 'test_helper'

class PublishZyncEventSubscriberTest < ActiveSupport::TestCase

  class OIDCApplicationEventTest < ActiveSupport::TestCase
    attr_reader :event, :subscriber, :publisher

    setup do
      service = FactoryBot.create(:simple_service, backend_version: 'oauth')
      application = FactoryBot.create(:simple_cinstance, service: service)
      @event = Applications::ApplicationCreatedEvent.create(application, nil)
      @publisher = mock('publisher')
      @subscriber = PublishZyncEventSubscriber.new(publisher)
    end

    test 'publish Zync Event for OIDC auth always' do
      publisher.expects(:call).times(3).returns(:ok)

      Rails.configuration.zync.stubs(skip_non_oidc_applications: false)
      assert subscriber.call(event)

      Rails.configuration.zync.stubs(skip_non_oidc_applications: true)
      assert subscriber.call(event)

      Rails.configuration.zync.stubs(skip_non_oidc_applications: nil)
      assert subscriber.call(event)
    end
  end

  class NonOIDCApplicationEventTest < ActiveSupport::TestCase
    attr_reader :event, :subscriber, :publisher

    setup do
      service = FactoryBot.create(:simple_service)
      application = FactoryBot.create(:simple_cinstance, service: service)
      @event = Applications::ApplicationCreatedEvent.create(application, nil)
      @publisher = mock('publisher')
      @subscriber = PublishZyncEventSubscriber.new(publisher)
    end

    test 'publish Zync Event by if not skipped' do
      publisher.expects(:call).times(2).returns(:ok)
      Rails.configuration.zync.stubs(skip_non_oidc_applications: false)
      assert subscriber.call(event)

      Rails.configuration.zync.stubs(skip_non_oidc_applications: nil)
      assert subscriber.call(event)
    end

    test 'do not publish Zync Event if skipped' do
      publisher.expects(:call).never
      Rails.configuration.zync.stubs(skip_non_oidc_applications: true)
      assert_nil subscriber.call(event)
    end
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
