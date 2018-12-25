require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class User::RolesTest < ActiveSupport::TestCase
  test 'default role is :member' do
    user = User.create!(:username => 'bob', :email => 'bob@example.com', :password => 'monkey')
    assert_equal :member, user.role
  end

  context 'different roles according to account type' do
    context 'class methods' do
      should 'buyers roles are the default ones' do
        assert_equal User.buyer_roles, User::DEFAULT_ROLES
      end

      should 'providers roles are the default ones plus more roles' do
        assert_equal User.provider_roles, User::DEFAULT_ROLES + User::MORE_ROLES
      end
    end

    context 'instance methods' do
      setup do
        @buyer_user = FactoryBot.create(:buyer_account).users.first
        @provider_user = FactoryBot.create(:provider_account).users.first
      end

      should 'buyer users have buyers possible roles' do
        assert_equal @buyer_user.account_roles, User.buyer_roles
      end

      should 'provider users have providers possible roles' do
        assert_equal @provider_user.account_roles, User.provider_roles
      end

      should 'users with no account have default roles' do
        assert_equal User.new.account_roles, User::DEFAULT_ROLES
      end
    end
  end

  test 'user has admin flag' do
    user = User.new
    refute user.admin?

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
    member = FactoryBot.create(:user, :account => regular_account)
    admin = regular_account.admins.first

    master_account.delete
    superadmin = master_account.admins.first

    refute member.superadmin?
    refute admin.superadmin?
    assert superadmin.superadmin?
  end

  test 'User#provider_admin? returns true if user is an admin of provider account' do
    account = FactoryBot.create(:provider_account)
    assert account.admins.first.provider_admin?
  end

  test 'User#provider_admin? returns false if user is non admin of provider account' do
    account = FactoryBot.create(:provider_account)
    user    = FactoryBot.create(:user, :account => account)

    refute user.provider_admin?
  end

  test 'User#provider_admin? return false if user is of non provider account' do
    account = FactoryBot.create(:account, :provider => false)

    refute account.admins.first.provider_admin?
  end

  test 'role is not mass assignable' do
    user = FactoryBot.create(:user)

    assert_no_change :of => lambda { user.role } do
      user.update_attributes(:role => :admin)
    end
  end

  test 'role accepts also string' do
    user = FactoryBot.create(:user)
    user.role = "admin"
    user.save!

    assert_equal :admin, user.role
  end

  context 'user roles metaprogrammed methods' do
    setup do
      @user = FactoryBot.create(:user)
    end

    User::ROLES.each do |user_role|

      should "#{user_role}! changes role to #{user_role}" do
        @user.send "make_#{user_role}".to_sym
        @user.reload

        assert_equal @user.role, user_role.to_sym
      end

      should "#{user_role}? returns true if role is #{user_role}" do
        @user.role = user_role
        @user.save!

        assert @user.send "#{user_role}?".to_sym
      end

    end
  end

end
