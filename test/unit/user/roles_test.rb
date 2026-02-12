# frozen_string_literal: true

require 'test_helper'

class User::RolesTest < ActiveSupport::TestCase
  test 'default role is :member' do
    user = User.create!(username: 'bob', email: 'bob@example.com', password: 'superSecret1234#')
    assert_equal :member, user.role
  end

  test 'buyers roles are the default ones' do
    assert_equal User::DEFAULT_ROLES, User.buyer_roles
  end

  test 'providers roles are the default ones plus more roles' do
    assert_equal User::DEFAULT_ROLES + User::MORE_ROLES, User.provider_roles
  end

  test 'buyer users have buyers possible roles' do
    buyer_user = FactoryBot.create(:buyer_account).users.first
    assert_equal User.buyer_roles, buyer_user.account_roles
  end

  test 'provider users have providers possible roles' do
    provider_user = FactoryBot.create(:provider_account).users.first
    assert_equal User.provider_roles, provider_user.account_roles
  end

  test 'users with no account have default roles' do
    assert_equal User::DEFAULT_ROLES, User.new.account_roles
  end

  test 'user has admin flag' do
    user = User.new
    assert_not user.admin?

    user.role = :admin
    assert user.admin?
  end

  test 'User.by_role' do
    admin = FactoryBot.build(:user)
    admin.role = :admin
    admin.save!

    member = FactoryBot.build(:user)
    member.role = :member
    member.save!

    assert_contains         User.by_role(:admin), admin
    assert_does_not_contain User.by_role(:admin), member
  end

  test 'User.admins' do
    admin = FactoryBot.build(:user)
    admin.role = :admin
    admin.save!

    member = FactoryBot.build(:user)
    member.role = :member
    member.save!

    assert_contains         User.admins, admin
    assert_does_not_contain User.admins, member
  end

  test 'User#superadmin? return true only if user is admin of the master account' do
    regular_account = FactoryBot.create(:account)
    member = FactoryBot.create(:user, account: regular_account)
    admin = regular_account.admins.first

    master_account.delete
    superadmin = master_account.admins.first

    assert_not member.superadmin?
    assert_not admin.superadmin?
    assert superadmin.superadmin?
  end

  test 'User#provider_admin? returns true if user is an admin of provider account' do
    account = FactoryBot.create(:provider_account)
    assert account.admins.first.provider_admin?
  end

  test 'User#provider_admin? returns false if user is non admin of provider account' do
    account = FactoryBot.create(:provider_account)
    user    = FactoryBot.create(:user, account: account)

    assert_not user.provider_admin?
  end

  test 'User#provider_admin? return false if user is of non provider account' do
    account = FactoryBot.create(:account, provider: false)

    assert_not account.admins.first.provider_admin?
  end

  test 'role is not mass assignable' do
    user = FactoryBot.create(:user)

    assert_no_change :of => -> { user.role } do
      user.update(role: :admin)
    end
  end

  test 'role accepts also string' do
    user = FactoryBot.create(:user)
    user.role = "admin"
    user.save!

    assert_equal :admin, user.role
  end

  User::ROLES.each do |user_role|
    test "#{user_role}! changes role to #{user_role}" do
      user = FactoryBot.create(:user)
      user.send "make_#{user_role}".to_sym
      user.reload

      assert_equal user.role, user_role.to_sym
    end

    test "#{user_role}? returns true if role is #{user_role}" do
      user = FactoryBot.create(:user)
      user.role = user_role
      user.save!

      assert user.send "#{user_role}?".to_sym
    end
  end
end
