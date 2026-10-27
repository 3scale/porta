# frozen_string_literal: true

require 'test_helper'

class ActiveJobSidekiqTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @original_adapter = SendUserInvitationWorker.queue_adapter
    @account = FactoryBot.create(:simple_account)
    @country = @account.country
    @invitation = FactoryBot.create(:invitation, account: @account, sent_at: Time.current)
    @invitation.update!(sent_at: nil)
    SendUserInvitationWorker.queue_adapter = :sidekiq
  end

  teardown do
    SendUserInvitationWorker.queue_adapter = @original_adapter
    @invitation&.destroy!
    @account&.destroy!
    @country&.destroy!
  end

  test 'enqueues and processes the invitation job after the transaction commits' do
    Sidekiq::Testing.fake! do
      ActiveRecord::Base.transaction(requires_new: true) do
        @job = SendUserInvitationWorker.perform_later(@invitation)
        assert_empty queued_invitation_jobs
      end

      assert_equal 1, queued_invitation_jobs.size
      perform_invitation_job
      assert_not_nil @invitation.reload.sent_at
    end
  end

  test 'does not enqueue the invitation job when the transaction rolls back' do
    Sidekiq::Testing.fake! do
      ActiveRecord::Base.transaction(requires_new: true) do
        @invitation.update!(sent_at: Time.current)
        @job = SendUserInvitationWorker.perform_later(@invitation)
        assert_empty queued_invitation_jobs
        raise ActiveRecord::Rollback
      end

      assert_nil @invitation.reload.sent_at
      assert_empty queued_invitation_jobs
    end
  end

  private

  def queued_invitation_jobs
    Sidekiq::Queues['default'].select do |job|
      job['wrapped'] == 'SendUserInvitationWorker' && job.dig('args', 0, 'job_id') == @job.job_id
    end
  end

  def perform_invitation_job
    delivery = mock
    delivery.expects(:deliver_now!).once
    InvitationMailer.expects(:invitation).with { |invitation| invitation.id == @invitation.id }.returns(delivery)
    ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper.process_job(queued_invitation_jobs.sole)
  end
end
