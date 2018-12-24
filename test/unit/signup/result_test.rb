# frozen_string_literal: true

require 'test_helper'

class SignupResultTest < ActiveSupport::TestCase
  test 'Signup::Result raises Signup::Result::AccountMismatchError in initialize when then parameter account is different than the user account' do
    assert_raise Signup::Result::AccountMismatchError do
      Signup::Result.new(user: user, account: FactoryBot.create(:account))
    end
  end

  test '#valid? returns true is the user and the account are both valid' do
    assert user.valid?
    assert account.valid?
    assert signup_result.valid?
  end

  test '#valid? returns false if the user is valid but the account is not' do
    @account = FactoryBot.build(:account, org_name: nil)
    assert user.valid?
    refute account.valid?
    refute signup_result.valid?
  end

  test '#valid? returns false if the user is not valid but the account is' do
    user.username = nil
    refute user.valid?
    assert account.valid?
    refute signup_result.valid?
  end

  test '#persisted? returns true is the user and the account are both persisted' do
    user.save && account.save
    assert user.persisted?
    assert account.persisted?
    assert signup_result.persisted?
  end

  test '#persisted? returns false if the user is persisted but the account is not' do
    @account = FactoryBot.build(:account, org_name: nil)
    user.save
    assert user.persisted?
    refute account.persisted?
    refute signup_result.persisted?
  end

  test '#persisted? returns false if the user is not persisted but the account is' do
    account.save
    refute user.persisted?
    assert account.persisted?
    refute signup_result.persisted?
  end

  test '#save! saves the user and the account when both are valid' do
    signup_result.save!
    assert user.persisted?
    assert account.persisted?
  end

  test '#save! saves the account first_admin_id to the user id' do
    signup_result.save!
    assert_equal user.id, account.first_admin_id
  end

  test '#save! raises ActiveRecord::RecordInvalid when the user is invalid' do
    user.username = nil
    assert_raise ActiveRecord::RecordInvalid do
      signup_result.save!
    end
    refute user.persisted?
    refute account.persisted?
  end

  test '#save! raises ActiveRecord::RecordInvalid when the account is invalid' do
    @account = FactoryBot.build(:account, org_name: nil)
    assert_raise ActiveRecord::RecordInvalid do
      signup_result.save!
    end
    refute user.persisted?
    refute account.persisted?
  end

  test '#save! raises ActiveRecord::RecordInvalid when @errors has errors' do
    signup_result.add_error(attribute: :plans, message: 'Error for testing purposes')
    assert_raise ActiveRecord::RecordInvalid do
      signup_result.save!
    end
    refute user.persisted?
    refute account.persisted?
  end

  test '#save saves the user and the account when both are valid' do
    signup_result.save
    assert user.persisted?
    assert account.persisted?
  end

  test '#save saves the account first_admin_id to the user id' do
    signup_result.save
    assert_equal user.id, account.first_admin_id
  end

  test '#save does not save and #errors return the error when the user is invalid' do
    user.username = nil
    signup_result.save
    refute user.persisted?
    refute account.persisted?
    assert_includes signup_result.errors[:user], 'Username is too short (minimum is 3 characters)'
  end

  test '#save does not save and #errors return the error when the account is invalid' do
    @account = FactoryBot.build(:account, org_name: nil)
    signup_result.save
    refute user.persisted?
    refute account.persisted?
    assert_includes signup_result.errors[:account], 'Organization/Group Name can\'t be blank'
    assert_equal 1, signup_result.errors.full_messages.length
  end

  test '#save does not save and #errors return the error when @errors has errors' do
    signup_result.add_error(attribute: :plans, message: 'Error for testing purposes')
    signup_result.save
    refute user.persisted?
    refute account.persisted?
    assert_includes signup_result.errors[:plans], 'Error for testing purposes'
    assert_equal 1, signup_result.errors.full_messages.length
  end

  test '#user_activate! activates the user if user.can_activate?' do
    user.update_attribute(:state, 'pending')
    assert user.can_activate?
    signup_result.user_activate!
    assert signup_result.user_active?
  end

  test '#user_activate! raises StateMachines::InvalidTransition if !user.can_activate?' do
    user.update_attribute(:state, 'suspended')
    refute user.can_activate?
    assert_raise StateMachines::InvalidTransition do
      signup_result.user_activate!
    end
    refute signup_result.user_active?
  end

  test '#user_activate activates the user if user.can_activate?' do
    user.update_attribute(:state, 'pending')
    assert user.can_activate?
    signup_result.user_activate
    assert signup_result.user_active?
  end

  test '#user_activate does not activate the user if !user.can_activate? and returns false ' do
    user.update_attribute(:state, 'suspended')
    refute user.can_activate?
    refute signup_result.user_activate
    refute signup_result.user_active?
  end

  test '#account_approve! approves if account.can_approve?' do
    account.update_attribute(:state, 'created')
    assert account.can_approve?
    signup_result.account_approve!
    assert signup_result.account_approved?
  end

  test '#account_approve! raises StateMachines::InvalidTransition if !account.can_approve?' do
    account.update_attribute(:state, 'approved')
    refute account.can_approve?
    assert_raise StateMachines::InvalidTransition do
      signup_result.account_approve!
    end
  end

  test '#account_approve approves if account.can_approve?' do
    account.update_attribute(:state, 'created')
    assert account.can_approve?
    assert signup_result.account_approve
    assert signup_result.account_approved?
  end

  test '#account_approve does not activate the user if !user.approve? and returns false ' do
    account.update_attribute(:state, 'approved')
    refute account.can_approve?
    refute signup_result.account_approve
  end

  class SignupResultWithAccessTokenTest < SignupResultTest
    test 'build and read access token through signup_result' do
      assert_difference signup_result.user.access_tokens.method(:count) do
        signup_result.save!
        assert_equal signup_result.user.access_tokens.first!, signup_result.access_token
      end
    end

    private

    def signup_result_class
      ::Signup::ResultWithAccessToken
    end
  end

  private

  def user
    @user ||= FactoryBot.build(:user, account: account)
  end

  def account
    @account ||= FactoryBot.build(:account_without_users)
  end

  def signup_result
    @signup_result ||= signup_result_class.new(user: user, account: account)
  end

  def signup_result_class
    ::Signup::Result
  end
end