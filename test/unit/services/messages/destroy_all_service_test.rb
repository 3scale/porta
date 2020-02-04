# frozen_string_literal: true

require 'test_helper'

class Messages::DestroyAllServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @message  = FactoryBot.create(:received_message, hidden_at: DateTime.yesterday)
    @account  = @message.receiver
    @messages = MessageRecipient.where(id: @message.id)
  end

  def test_run!
    Sidekiq::Testing.fake! do
      assert_nil @message.deleted_at

      ::Messages::DestroyAllService.run!({
                                           account: @account,
                                           association_class: MessageRecipient,
                                           scope: :hidden
                                         })

      @message.reload

      assert_not_equal nil, @message.deleted_at
    end
  end

  def test_run_with_sidekiq_job
    perform_enqueued_jobs do
      Sidekiq::Testing.inline! do
        assert @message.present?

        ::Messages::DestroyAllService.run!({
                                             account: @account,
                                             association_class: MessageRecipient,
                                             scope: :hidden
                                           })

        assert_raise(ActiveRecord::RecordNotFound) do
          @message.reload
        end
      end
    end
  end
end
