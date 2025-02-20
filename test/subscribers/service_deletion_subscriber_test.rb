require 'test_helper'

class ServiceDeletionSubscriberTest < ActiveSupport::TestCase
  def test_create
    service = FactoryBot.create(:simple_service)
    event = Services::ServiceScheduledForDeletionEvent.create(service)

    DeleteObjectHierarchyWorker.expects(:delete_later).with(service)

    ServiceDeletionSubscriber.new.after_commit(event)
  end
end
