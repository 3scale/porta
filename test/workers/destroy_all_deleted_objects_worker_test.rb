require 'test_helper'

class DestroyAllDeletedObjectsWorkerTest < ActiveSupport::TestCase

  def setup
    @message = FactoryBot.create(:received_message, deleted_at: DateTime.yesterday)
  end

  def test_perform
    Sidekiq::Testing.inline! do
      assert @message.present?

      DestroyAllDeletedObjectsWorker.perform_async('MessageRecipient')

      assert_raise(ActiveRecord::RecordNotFound) do
        @message.reload
      end
    end
  end
end
