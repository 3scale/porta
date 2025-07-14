# frozen_string_literal: true

require 'test_helper'

class DeleteAllStaleObjectsWorkerTest < ActiveSupport::TestCase
  test "actually deleting stuff" do
    message = FactoryBot.create(:message)
    stale_message = FactoryBot.create(:message)
    stale_message.update_column(:sender_id, 0)
    stale_message2 = FactoryBot.create(:message)
    stale_message2.update_column(:sender_id, 0)

    assert_number_of_queries(1, matching: /DELETE|SELECT/) do
      DeleteAllStaleObjectsWorker.perform_now(Message.name)
    end

    assert message.reload
    assert_raise(ActiveRecord::RecordNotFound) { stale_message.reload }
    assert_raise(ActiveRecord::RecordNotFound) { stale_message2.reload }
  end
end
