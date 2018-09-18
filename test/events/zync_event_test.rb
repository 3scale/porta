require 'test_helper'

class ZyncEventTest < ActiveSupport::TestCase
  def test_create_application
    application = FactoryGirl.build_stubbed(:simple_cinstance)

    event = ApplicationRelatedEvent.new(id: application.id, tenant_id: application.provider_account.id)

    assert ZyncEvent.create(event)
  end

  def test_dependencies
    application = FactoryGirl.create(:simple_cinstance)
    parent_event = RailsEventStore::Event.new

    assert event = ZyncEvent.create(parent_event, application)

    assert_equal [ service = application.service, service.proxy ], event.dependencies
  end

  def test_record
    application = FactoryGirl.create(:simple_cinstance)
    parent_event = RailsEventStore::Event.new

    assert event = ZyncEvent.create(parent_event, application)

    assert_equal application, event.record
  end

  def test_model
    application = FactoryGirl.build_stubbed(:simple_cinstance)
    parent_event = RailsEventStore::Event.new

    assert event = ZyncEvent.create(parent_event, application)

    assert_equal application.class, event.model
  end
end
