# frozen_string_literal: true

require 'test_helper'

class UserEventSegmentSubscriberTest < ActiveSupport::TestCase
  test 'when UserDeletedEvent, and SegmentDeletionConfig is enabled, it enqueues SegmentDeleteUserWorker' do
    Features::SegmentDeletionConfig.stubs(enabled?: true)
    user = FactoryBot.build_stubbed(:admin, account: FactoryBot.build_stubbed(:simple_account))
    event = Users::UserDeletedEvent.create(user)

    SegmentDeleteUserWorker.expects(:perform_later).with(event.event_id)

    UserEventSubscriber.new.after_commit(event)
  end

  test 'when UserDeletedEvent, but SegmentDeletionConfig is disabled, it does not enqueue SegmentDeleteUserWorker' do
    Features::SegmentDeletionConfig.stubs(enabled?: false)
    user = FactoryBot.build_stubbed(:admin, account: FactoryBot.build_stubbed(:simple_account))
    event = Users::UserDeletedEvent.create(user)

    SegmentDeleteUserWorker.expects(:perform_later).never

    UserEventSubscriber.new.after_commit(event)
  end
end
