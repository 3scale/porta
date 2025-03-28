# frozen_string_literal: true

require 'test_helper'

class DeleteAllStaleObjectsWorkerTest < ActiveSupport::TestCase
  test "calls #delete_all on the stale relation in batches" do
    Kernel.stubs(:sleep) # avoid 1 second waits

    relation = mock(:message_relation)
    relation.expects(:limit).with(500).returns(relation).twice
    relation.expects(:delete_all).returns(500, 0).twice
    Message.stubs(:stale).returns(relation)

    relation = mock(:message_recipient_relation)
    relation.expects(:limit).with(500).returns(relation).twice
    relation.expects(:delete_all).returns(500, 499).twice
    MessageRecipient.expects(:stale).returns(relation).twice

    DeleteAllStaleObjectsWorker.perform_now(MessageRecipient.name, Message.name)
  end

  test "actually deleting stuff" do
    message = FactoryBot.create(:message)
    stale_message = FactoryBot.create(:message)
    stale_message.update_column(:sender_id, 0)

    DeleteAllStaleObjectsWorker.perform_now(Message.name)

    assert message.reload
    assert_raise(ActiveRecord::RecordNotFound) { stale_message.reload }
  end
end
