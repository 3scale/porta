require 'test_helper'

class ZyncEventTest < ActiveSupport::TestCase
  def test_create_application
    application = FactoryBot.build_stubbed(:simple_cinstance)

    event = ApplicationRelatedEvent.new(id: application.id, tenant_id: application.provider_account.id)

    assert ZyncEvent.create(event)
  end

  def test_dependencies
    application = FactoryBot.create(:simple_cinstance)
    parent_event = RailsEventStore::Event.new

    assert event = ZyncEvent.create(parent_event, application)

    assert_equal [ service = application.service, service.proxy ], event.dependencies
  end

  def test_non_persisted_dependencies_for_application
    application = FactoryBot.build(:simple_cinstance, service: FactoryBot.create(:simple_service))
    assert event = ZyncEvent.create(Applications::ApplicationDeletedEvent.create(application), application)
    assert_equal [application.service_id], event.dependencies.map(&:id)
  end

  def test_non_persisted_dependencies_for_proxy
    proxy = FactoryBot.build(:proxy, service: FactoryBot.create(:simple_service))
    assert event = ZyncEvent.create(OIDC::ProxyChangedEvent.create(proxy), proxy)
    assert_equal [proxy.service_id], event.dependencies.map(&:id)
  end

  def test_record
    application = FactoryBot.create(:simple_cinstance)
    parent_event = RailsEventStore::Event.new

    assert event = ZyncEvent.create(parent_event, application)

    assert_equal application, event.record
  end

  def test_model
    application = FactoryBot.build_stubbed(:simple_cinstance)
    parent_event = RailsEventStore::Event.new

    assert event = ZyncEvent.create(parent_event, application)

    assert_equal application.class, event.model
  end
end
