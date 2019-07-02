# frozen_string_literal: true

require 'test_helper'

class EventStore::Services::ServiceDeletedEventTest < ActiveSupport::TestCase
  test 'default_scope' do
    create_publish_service_deleted_event
    ::Applications::ApplicationDeletedEvent.create_and_publish!(Cinstance.new({id: 1, tenant_id: 1}, without_protection: true))

    result_service_events = EventStore::Services::ServiceDeletedEvent.pluck(:id)
    expected_service_events = EventStore::Event.where(event_type: ::Services::ServiceDeletedEvent).pluck(:id)
    assert_equal expected_service_events, result_service_events
  end

  test '.by_object_id' do
    [9, 90].each { |service_id| create_publish_service_deleted_event(service_id) }

    EventStore::Services::ServiceDeletedEvent.by_object_id(9).each do |event_result|
      assert_equal 9, event_result.data[:service_id]
    end
  end

  private

  def create_publish_service_deleted_event(service_id = 1)
    ::Services::ServiceDeletedEvent.create_and_publish!(Service.new({id: service_id, tenant_id: 1}, without_protection: true))
  end
end
