# frozen_string_literal: true

require 'test_helper'

class UserEventSegmentSubscriberTest < ActiveSupport::TestCase
  test 'when Users::UserDeletedEvent, it calls to SegmentDeleteService.delete_user' do
    user = FactoryBot.build_stubbed(:admin, account: FactoryBot.build_stubbed(:simple_account))
    event = Users::UserDeletedEvent.create(user)

    SegmentDeleteService.expects(:delete_user).with(event)

    UserEventSegmentSubscriber.new.after_commit(event)
  end
end
