require 'test_helper'

class Services::ServiceDeletedEventTest < ActiveSupport::TestCase

  def test_create
    service = FactoryBot.build_stubbed(:simple_service, id: 1, name: 'Alaska')
    event   = Services::ServiceDeletedEvent.create(service)

    assert event
    assert event.service_name, service.name
    assert event.service_id, service.id
    assert event.provider, service.provider
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
end
