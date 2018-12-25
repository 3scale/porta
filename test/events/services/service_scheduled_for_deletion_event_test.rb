require 'test_helper'

class Services::ServiceScheduledForDeletionEventTest < ActiveSupport::TestCase

  def test_create
    service = FactoryBot.build_stubbed(:simple_service, id: 1, name: 'Alaska')
    event   = Services::ServiceScheduledForDeletionEvent.create(service)

    assert event
    assert event.service_id, service.id
    assert event.service_name, service.name
    assert event.provider, service.provider
  end
end
