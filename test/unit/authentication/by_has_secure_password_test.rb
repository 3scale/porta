require 'test_helper'
class Authentication::ByHasSecurePasswordTest < ActiveSupport::TestCase

  def setup
    @user = FactoryGirl.create(:simple_user, account: nil)
  end

  test 'User creatd without old crypted_password' do
    refute @user.crypted_password
    refute @user.salt
  end

  test 'user without password_digest' do
    reset_to_old_crypted_password!
    # Authenticate the old way
    assert @user.authenticated?('supersecret')
  end

  test 'new user with password_digest' do
    assert @user.authenticate('supersecret')
    assert @user.authenticated?('supersecret')
  end

  test 'transparently migrate user' do
    @user.update_column(:password_digest, nil)
    refute @user.authenticated?('supersecret')
    @user.transparently_migrate_password('another_password')
    @user.reload
    assert @user.authenticated?('another_password')
  end

  test 'unset old digest after' do
    reset_to_old_crypted_password!
    ThreeScale::Analytics::UserTracking.any_instance.expects(:track).with('Migrated to BCrypt')
    assert @user.transparently_migrate_password('supersecret')
    assert_nil @user.crypted_password
    assert_nil @user.salt
    assert @user.authenticated?('supersecret')
  end

  test 'Internal Strategy authentication migrates to has_secure_password when user can login' do
    reset_to_old_crypted_password!
    provider = FactoryGirl.create(:simple_provider)
    strategy = Authentication::Strategy::Internal.new(provider, true)
    @user.update_columns(account_id: provider.id, password_digest: nil)
    @user.activate!
    refute @user.authenticate('supersecret')
    assert found_user = strategy.authenticate(username: @user.username, password: 'supersecret')
    assert_equal @user, found_user
    assert found_user.authenticate('supersecret')

    found_user.update_column(:crypted_password, 'bulk-string')
    assert found_user.authenticated?('supersecret')
  end

  test 'Internal Strategy authentication migrates to has_secure_password when user cannot login' do
    reset_to_old_crypted_password!
    provider = FactoryGirl.create(:simple_provider)
    strategy = Authentication::Strategy::Internal.new(provider, true)
    @user.update_columns(account_id: provider.id, password_digest: nil)
    refute @user.authenticate('supersecret')
    refute strategy.authenticate(username: @user.username, password: 'supersecret')
    @user.reload
    assert @user.authenticate('supersecret')

    @user.update_column(:crypted_password, 'bulk-string')
    assert @user.authenticated?('supersecret')
  end

  protected

  def reset_to_old_crypted_password!
    # FIXME: Weird stubbing...
    # Maybe not testing new_record but better:
    # - presence of crypted_password
    # - absence of password_digest
    # Encrypting the user password manually with the old encyrption way
    @user.stubs(new_record?: true)
    @user.encrypt_password
    @user.unstub(:new_record?)
    @user.save!
    @user.reload
    assert @user.crypted_password
    assert @user.salt
    @user.update_column(:password_digest, nil)
    # Do not authenticate through has_secure_password
    refute @user.authenticate('supersecret')
  end
end
