# frozen_string_literal: true

require 'test_helper'
require 'admin_section'

class User::PermissionsTest < ActiveSupport::TestCase
  test 'has_permission' do
    user = FactoryBot.build_stubbed(:simple_user)

    refute user.has_permission?(:plans)

    user.admin_sections = [:plans]

    assert user.has_permission?(:plans)
  end

  test 'admin_sections= with a section name' do
    user = FactoryBot.create(:simple_user)
    permissions_count = MemberPermission.method(:count)

    assert user.admin_sections.empty?
    assert_equal 0, permissions_count.call

    assert_no_difference permissions_count do
      user.admin_sections = [:settings]
    end

    assert_difference permissions_count do
      user.save!
    end

    assert_difference permissions_count, -1 do
      user.admin_sections = []
    end
  end

  test 'admin_sections= for "service" section' do
    user = FactoryBot.create(:simple_user)
    permissions_count = MemberPermission.method(:count)

    assert user.admin_sections.empty?
    assert_equal 0, permissions_count.call

    assert_no_difference permissions_count do
      user.admin_sections = [:services, :settings]
    end

    assert_difference permissions_count, 2 do
      user.save!
    end

    # when sections are removed, the enabled services remain the same, and are not deleted
    assert_difference permissions_count, -1 do
      user.admin_sections = []
    end
  end

  # this is used from the UI
  test 'member_permission_ids=' do
    user = FactoryBot.build_stubbed(:simple_user)

    user.member_permission_ids = nil

    assert_equal Set.new, user.admin_sections

    user.member_permission_ids = [:portal]
    assert_equal Set[:portal], user.admin_sections
  end

  test 'member_permission_service_ids=' do
    user = FactoryBot.create(:simple_user, admin_sections: [:partners])
    user.stubs(:existing_service_ids).returns([42])

    assert user.has_access_to_service?(42)
    assert_equal 1, user.admin_sections.size

    user.update(member_permission_service_ids: [""]) # FIXME: []
    assert_not user.has_access_to_service?(42)
    assert_equal Set[:partners, :services], user.admin_sections

    user.update(member_permission_service_ids: nil)
    assert user.has_access_to_service?(42)
    assert_equal Set[:partners], user.admin_sections
  end

  test 'member_permission_service_ids= filters the services list before saving' do
    user = FactoryBot.build_stubbed(:simple_user, admin_sections: [:services])

    user.stubs(:existing_service_ids).returns([1,2])

    user.member_permission_service_ids = [1,111]

    assert_equal [1], user.services_member_permission.service_ids
  end

  test 'services_member_permission' do
    user = FactoryBot.build_stubbed(:simple_user)

    refute user.services_member_permission

    permission = user.member_permissions.build(admin_section: :services)

    assert_equal permission, user.services_member_permission
  end

  test 'has_access_to_service?' do
    user = FactoryBot.build_stubbed(:simple_user, admin_sections: [:services])
    refute user.has_access_to_service?(42)

    user.admin_sections = [:services]
    refute user.has_access_to_service?(42)
    user.services_member_permission.service_ids = [42]
    assert user.has_access_to_service?(42)

    user.admin_sections = [:plans]
    assert user.has_access_to_service?(42)
  end

  test 'has_access_to_all_services?' do
    user = FactoryBot.build_stubbed(:simple_user)
    assert_not user.has_access_to_all_services?

    user.member_permission_ids = [:portal]
    assert_not user.has_access_to_all_services?

    user.member_permission_ids = [:plans]
    assert user.has_access_to_all_services?

    user.member_permission_service_ids = [''] # FIXME: []
    assert_not user.has_access_to_all_services?

    user.stubs(:admin?).returns(true)
    assert user.has_access_to_all_services?
  end

  test '#access_to_service_admin_sections? when no accessible services' do
    user = FactoryBot.build(:simple_user)
    user.stubs(:accessible_services?).returns(false)
    refute user.access_to_service_admin_sections?

    AdminSection::SERVICE_PERMISSIONS.each do |section|
      user.member_permission_ids = [section]
      refute user.access_to_service_admin_sections?
    end
  end

  test '#access_to_service_admin_sections? when any accessible services' do
    user = FactoryBot.build(:simple_user)
    user.stubs(:accessible_services?).returns(true)
    refute user.access_to_service_admin_sections?

    AdminSection::SERVICE_PERMISSIONS.each do |section|
      user.member_permission_ids = [section]
      assert user.access_to_service_admin_sections?
    end
  end
end
