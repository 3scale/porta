require 'test_helper'

class MemberPermissionTest < ActiveSupport::TestCase

  test 'service_ids' do
    permission = MemberPermission.new

    permission.service_ids = nil
    assert_equal [], permission.service_ids

    permission.service_ids = ['42']
    assert_equal [42], permission.service_ids

    permission.service_ids = [43]
    permission.admin_section = :services

    assert permission.save!

    permission.reload

    assert_equal permission.service_ids, [43]
  end

  test 'section_name' do
    permission = MemberPermission.new(admin_section: :services)
    assert_equal 'services', permission.section_name
  end

  test 'has_service' do
    permission = MemberPermission.new(service_ids: ['42'])
    service = Service.new

    service.id = 42

    assert permission.has_service?(service)
    assert permission.has_service?(service.id)

    service.id = 43

    refute permission.has_service?(service)
    refute permission.has_service?(service.id)
  end

  test 'admin_section' do
    permission = MemberPermission.new
    refute permission.valid?

    permission.admin_section = :plans
    assert permission.valid?

    permission.admin_section = :services
    assert permission.valid?
  end
end
