# frozen_string_literal: true

require 'test_helper'

class Users::UserDeletedEventTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  setup do
    @tenant_account = FactoryBot.create(:simple_provider, provider_account: master_account)
  end

  attr_reader :tenant_account

  test 'it is saved with the right data when user is a developer and its tenant is still persisted' do
    developer_account = FactoryBot.create(:simple_buyer, provider_account: tenant_account)
    developer_user = FactoryBot.create(:user, account: developer_account)

    event = Users::UserDeletedEvent.create(developer_user.reload)
    Rails.application.config.event_store.publish_event(event)

    event_stored = EventStore::Repository.find_event!(event.event_id)
    assert_equal tenant_account.id, event_stored.metadata[:provider_id]
  end

  test 'it is saved with the right data when user is a developer and its tenant is not persisted anymore' do
    developer_account = FactoryBot.create(:simple_buyer, provider_account: tenant_account)
    developer_user = FactoryBot.create(:user, account: developer_account)
    tenant_id = tenant_account.id

    tenant_account.delete

    event = Users::UserDeletedEvent.create(developer_user.reload)
    Rails.application.config.event_store.publish_event(event)

    event_stored = EventStore::Repository.find_event!(event.event_id)
    assert_equal tenant_id, event_stored.metadata[:provider_id]
  end

  test 'it is saved with the right data when user is a tenant and its account is still persisted' do
    tenant_user = FactoryBot.create(:user, account: tenant_account)

    event = Users::UserDeletedEvent.create(tenant_user.reload)
    Rails.application.config.event_store.publish_event(event)

    event_stored = EventStore::Repository.find_event!(event.event_id)
    assert_equal tenant_account.id, event_stored.metadata[:provider_id]
  end

  test 'it is saved with the right data when user is a tenant and its account is not persisted anymore' do
    tenant_user = FactoryBot.create(:user, account: tenant_account)

    tenant_account.delete

    event = Users::UserDeletedEvent.create(tenant_user.reload)
    Rails.application.config.event_store.publish_event(event)

    event_stored = EventStore::Repository.find_event!(event.event_id)
    assert_equal tenant_account.id, event_stored.metadata[:provider_id]
  end
end
