require 'test_helper'

class SegmentSubscriberTest < ActiveSupport::TestCase

  def test_account_deleted
    subscriber = SegmentSubscriber.new(:account_deleted)

    provider = FactoryGirl.create(:provider_account)

    event = Accounts::AccountDeletedEvent.create(provider)
    user_id = provider.first_admin.id

    segment = ThreeScale::Analytics::UserTracking::Segment
    segment.expects(:group).with(
      has_entries(user_id: user_id, group_id: provider.id,
                  traits: { state: 'deleted' })
    )
    segment.expects(:track).with(
      has_entries(user_id: user_id, event: 'Account Deleted')
    )
    segment.expects(:identify).with(
      has_entries(user_id: user_id, traits: { state: 'deleted' })
    )

    subscriber.call(event)
  end

  def test_account_deleted_buyer
    buyer = FactoryGirl.create(:simple_buyer)
    event = Accounts::AccountDeletedEvent.create(buyer)

    subscriber = SegmentSubscriber.new(:account_deleted)

    refute subscriber.call(event)
  end
end
