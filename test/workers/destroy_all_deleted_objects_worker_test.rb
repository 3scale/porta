# frozen_string_literal: true

require 'test_helper'

class DestroyAllDeletedObjectsWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def test_perform_destroys_message_recipient
    message = FactoryBot.create(:received_message, deleted_at: DateTime.yesterday)
    perform_enqueued_jobs do
      assert_difference(MessageRecipient.method(:count), -1) do
        DestroyAllDeletedObjectsWorker.perform_later('MessageRecipient')
      end
      assert_raise(ActiveRecord::RecordNotFound) { message.reload }
    end
  end

  def test_perform_enqueues_delete_object_hierarchy_worker_jobs
    provider = FactoryBot.create(:simple_provider)
    services = FactoryBot.create_list(:simple_service, 2, account: provider)
    services.first.mark_as_deleted!

    DeleteObjectHierarchyWorker.expects(:delete_later).once.with do |object, _hierarchy|
      object.id == services.first.id
    end

    perform_enqueued_jobs do
      DestroyAllDeletedObjectsWorker.perform_later(Service.to_s)
    end
  end
end
