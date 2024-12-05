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

    # all values have the same effect
    [[], [""], ["[]"], ["xyz"]].each do |service_ids_empty_value|
      user.update(member_permission_service_ids: service_ids_empty_value)
      assert_not user.has_access_to_service?(42)
      assert_equal Set[:partners, :services], user.admin_sections
      assert_equal [], user.member_permission_service_ids
    end

    [nil, ""].each do |enable_all_value|
      user.update(member_permission_service_ids: enable_all_value)
      assert user.has_access_to_service?(42)
      assert_equal Set[:partners], user.admin_sections
    end

    previous_permissions = user.member_permissions
    ["abc", 123].each do |invalid_value|
      user.update(member_permission_service_ids: invalid_value)
      assert_equal previous_permissions, user.reload.member_permissions
    end

    # when setting numeric values and empty value, empty values are ignored
    [[42, ''], [42, "[]"]].each do |service_ids|
      user.update(member_permission_service_ids: service_ids)
      assert user.has_access_to_service?(42)
      assert_equal Set[:partners, :services], user.admin_sections
      assert_equal [42], user.member_permission_service_ids
    end

    # if 0 is a valid service_id, it can be set as an allowed service
    user.stubs(:existing_service_ids).returns([0, 42])
    user.update(member_permission_service_ids: ['0'])
    assert user.has_access_to_service?(0)
    assert_equal [0], user.member_permission_service_ids
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

    user.member_permission_service_ids = []
    assert_not user.has_access_to_all_services?

    user.stubs(:admin?).returns(true)
    assert user.has_access_to_all_services?
  end

  test '#permitted_services_status' do
    user = FactoryBot.build_stubbed(:simple_user)
    user.stubs(:existing_service_ids).returns([42])

    assert_equal :none, user.permitted_services_status

    user.member_permission_ids = [:portal]
    assert_equal :none, user.permitted_services_status

    user.member_permission_ids = [:plans]
    assert_equal :all, user.permitted_services_status

    user.member_permission_service_ids = [24]
    assert_equal :none, user.permitted_services_status

    user.member_permission_service_ids = [42]
    assert_equal :selected, user.permitted_services_status

    user.member_permission_service_ids = []
    assert_equal :none, user.permitted_services_status

    user.stubs(:admin?).returns(true)
    assert_equal :all, user.permitted_services_status
  end

  test '#service_permissions_selected?' do
    user = FactoryBot.build_stubbed(:simple_user)
    %i[partners plans monitoring].each do |section|
      user.stubs(:member_permission_ids).returns([section])
      assert user.service_permissions_selected?
    end

    %i[portal finance settings policy_registry].each do |section|
      user.stubs(:member_permission_ids).returns([section])
      assert_not user.service_permissions_selected?
    end
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
