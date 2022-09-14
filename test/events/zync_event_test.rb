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

  def test_create_dependencies
    application = FactoryBot.create(:simple_cinstance)
    event = ZyncEvent.create(RailsEventStore::Event.new, application)

    dependencies = [service = application.service, service.proxy]
    event.expects(:dependencies).returns(dependencies)
    dependencies.each { |dependency| ZyncEvent.expects(:create).with(event, dependency) }

    event.create_dependencies
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

  def test_merges_metadata
    application = FactoryBot.build_stubbed(:simple_cinstance, tenant_id: 123)
    date = Date.parse('2019-09-01')
    travel_to(date) do
      parent_event = RailsEventStore::Event.new metadata: {foo: :bar}

      event = ZyncEvent.create(parent_event, application)
      assert_equal({provider_id: application.tenant_id, foo: :bar, timestamp: date }, event.metadata)
    end
  end
end
