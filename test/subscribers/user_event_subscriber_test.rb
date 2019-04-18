# frozen_string_literal: true

require 'test_helper'

class UserEventSegmentSubscriberTest < ActiveSupport::TestCase
  test 'when Users::UserDeletedEvent, it enqueues SegmentDeleteUserWorker' do
    user = FactoryBot.build_stubbed(:admin, account: FactoryBot.build_stubbed(:simple_account))
    event = Users::UserDeletedEvent.create(user)

    SegmentDeleteUserWorker.expects(:perform_later).with(event.event_id)

    UserEventSubscriber.new.after_commit(event)
  end
end
