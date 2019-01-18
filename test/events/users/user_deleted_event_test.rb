# frozen_string_literal: true

require 'test_helper'

class Users::UserDeletedEventTest < ActiveSupport::TestCase
  test 'the event is persisted with all the necessary attributes' do
    account = FactoryBot.create(:simple_provider, provider_account: master_account)
    user = FactoryBot.create(:user, account: account)

    event = Users::UserDeletedEvent.create(user)
    Rails.application.config.event_store.publish_event(event)

    event_stored = EventStore::Repository.find_event!(event.event_id)
    assert_equal user.id, event_stored.user_id
    assert_equal event.metadata[:provider_id], master_account.id
  end

  test 'the event is persisted and with the necessary attributes when its associations are already destroyed' do
    provider = FactoryBot.create(:simple_provider)
    account = FactoryBot.create(:simple_buyer, provider_account: provider)
    user = FactoryBot.create(:user, account: account)

    provider.delete

    event = Users::UserDeletedEvent.create(user.reload)
    Rails.application.config.event_store.publish_event(event)

    assert_not_nil(event_stored = EventStore::Repository.find_event(event.event_id))
  end
end
