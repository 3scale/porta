require 'test_helper'

class User::PermissionsTest < ActiveSupport::TestCase

  test 'has_permission' do
    user = FactoryGirl.build_stubbed(:simple_user)

    refute user.has_permission?(:plans)

    user.admin_sections = [:plans]

    assert user.has_permission?(:plans)
  end

  test 'admin_sections= with a section name' do
    user = FactoryGirl.create(:simple_user)
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
    user = FactoryGirl.create(:simple_user)
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
    user = FactoryGirl.build_stubbed(:simple_user)

    user.member_permission_ids = nil

    assert_equal Set.new, user.admin_sections

    user.member_permission_ids = [:portal]
    assert_equal Set[:portal], user.admin_sections
  end

  test 'member_permission_service_ids=' do
    user = FactoryGirl.build_stubbed(:simple_user, admin_sections: [:services])
    user.stubs(:existing_service_ids).returns([42])

    refute user.has_access_to_service?(42)
    assert_equal 1, user.admin_sections.size

    user.member_permission_service_ids = [42]
    assert user.has_access_to_service?(42)
    assert_equal Set[:services], user.admin_sections

    user.member_permission_service_ids = nil
    assert user.has_access_to_service?(42)
    assert_equal 0, user.admin_sections.size
  end

  test 'member_permission_service_ids= filters the services list before saving' do
    user = FactoryGirl.build_stubbed(:simple_user, admin_sections: [:services])

    user.stubs(:existing_service_ids).returns([1,2])

    user.member_permission_service_ids = [1,111]

    assert_equal [1], user.services_member_permission.service_ids
  end

  test 'services_member_permission' do
    user = FactoryGirl.build_stubbed(:simple_user)

    refute user.services_member_permission

    permission = user.member_permissions.build(admin_section: :services)

    assert_equal permission, user.services_member_permission
  end

  test 'has_access_to_service?' do
    user = FactoryGirl.build_stubbed(:simple_user, admin_sections: [:services])
    refute user.has_access_to_service?(42)

    user.admin_sections = [:services]
    refute user.has_access_to_service?(42)
    user.services_member_permission.service_ids = [42]
    assert user.has_access_to_service?(42)

    user.admin_sections = [:plans]
    assert user.has_access_to_service?(42)
  end

  test 'has_access_to_all_services?' do
    user = FactoryGirl.build_stubbed(:simple_user)
    assert user.has_access_to_all_services?

    user.admin_sections = [:services]
    refute user.has_access_to_all_services?

    # updating admin section doesn't remove service permissions
    user.admin_sections = [:plans]
    refute user.has_access_to_all_services?

    user.admin_sections = []
    user.stubs(:admin?).returns(true)
    assert user.has_access_to_all_services?
  end

  test '#forbidden_some_services?' do
    user = FactoryGirl.build(:simple_user)

    user.stubs(has_access_to_all_services?: true)
    user.account.stubs(provider_can_use?: true)
    refute user.forbidden_some_services?

    user.stubs(has_access_to_all_services?: true)
    user.account.stubs(provider_can_use?: false)
    refute user.forbidden_some_services?

    user.stubs(has_access_to_all_services?: false)
    user.account.stubs(provider_can_use?: false)
    refute user.forbidden_some_services?

    user.stubs(has_access_to_all_services?: false)
    user.account.stubs(provider_can_use?: true)
    assert user.forbidden_some_services?
  end

end
