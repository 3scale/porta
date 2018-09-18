require 'test_helper'

class Services::ServiceDeletedEventTest < ActiveSupport::TestCase

  def test_create
    service = FactoryGirl.build_stubbed(:simple_service, id: 1, name: 'Alaska')
    event   = Services::ServiceDeletedEvent.create(service)

    assert event
    assert event.service_name, service.name
    assert event.service_id, service.id
    assert event.provider, service.provider
  end

  def test_ability
    service = FactoryGirl.create(:service)
    admin   = FactoryGirl.build_stubbed(:simple_admin, account: service.account)
    member  = FactoryGirl.build_stubbed(:simple_user, account: service.account,
                                        admin_sections: [:partners, :services])

    service.destroy!
    event = Services::ServiceDeletedEvent.create(service)

    assert_cannot Ability.new(member), :show, event
    assert_can Ability.new(admin), :show, event

    member.member_permission_service_ids = [service.id]
    member.save!
    
    assert_can Ability.new(member), :show, event
  end
end
