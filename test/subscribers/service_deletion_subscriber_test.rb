require 'test_helper'

class ServiceDeletionSubscriberTest < ActiveSupport::TestCase
  def test_create
    service = FactoryBot.create(:simple_service)
    event = Services::ServiceScheduledForDeletionEvent.create(service)

    DeleteServiceHierarchyWorker.expects(:perform_later).with(service)

    ServiceDeletionSubscriber.new.after_commit(event)
  end
end
