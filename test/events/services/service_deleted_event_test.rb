# frozen_string_literal: true

require 'test_helper'

class Services::ServiceDeletedEventTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  def test_create
    service = FactoryBot.build_stubbed(:simple_service)
    event   = Services::ServiceDeletedEvent.create(service)

    assert_equal service.name, event.service_name
    assert_equal service.id, event.service_id

    # If we ever want to fetch the provider from anywhere, we should do it from the provider_id
    refute event.data.has_key?(:provider)
  end

  def test_ability
    service = FactoryBot.create(:service)
    admin   = FactoryBot.build_stubbed(:simple_admin, account: service.account)
    member  = FactoryBot.build_stubbed(:simple_user, account: service.account,
                                        admin_sections: [:partners, :services])

    member.member_permission_service_ids = [service.id]

    service.destroy!
    event = Services::ServiceDeletedEvent.create(service)

    assert_can Ability.new(member), :show, event

    # remove service 1 from member's allowed services by setting a non-existent ID
    member.member_permission_service_ids = [42]

    assert_cannot Ability.new(member), :show, event
    assert_can Ability.new(admin), :show, event
  end

  def test_create_and_publish_when_provider_does_not_exists_anymore
    provider = FactoryBot.create(:simple_provider)
    service = FactoryBot.create(:simple_service, account: provider)

    provider_id = provider.id
    provider.delete

    event = Services::ServiceDeletedEvent.create_and_publish!(service.reload)

    event_stored = EventStore::Repository.find_event!(event.event_id)
    assert_equal provider_id, event_stored.metadata.fetch(:provider_id)
  end

  def test_create_publish_find_when_provider_scheduled_for_deletion
    provider = FactoryBot.create(:simple_provider)
    service = FactoryBot.create(:simple_service, account: provider)
    provider.schedule_for_deletion!

    event = Services::ServiceDeletedEvent.create_and_publish!(service.reload)

    provider.delete

    assert EventStore::Repository.find_event(event.event_id)
  end
end
