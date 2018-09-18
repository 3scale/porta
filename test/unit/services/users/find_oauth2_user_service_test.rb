require 'test_helper'

class Users::FindOauth2UserServiceTest < ActiveSupport::TestCase

  UsersDouble = Class.new(ActiveRecord::Relation)

  def test_run
    service.any_instance.expects(:find).returns(true)
    assert service.run(ThreeScale::OAuth2::UserData.new, auth_provider, relation)
  end

  def test_find
    user = User.new

    service.any_instance.expects(:find_by_sso_authorization).returns(user).once
    service.any_instance.expects(:find_by_authentication_id).never
    service.any_instance.expects(:find_by_email).never
    assert_equal user, service.run(user_data, auth_provider, relation).user

    service.any_instance.expects(:find_by_sso_authorization).returns(nil).once
    service.any_instance.expects(:find_by_authentication_id).returns(user)
    service.any_instance.expects(:find_by_email).never
    assert_equal user, service.run(user_data, auth_provider, relation).user

    service.any_instance.expects(:find_by_sso_authorization).returns(nil).once
    service.any_instance.expects(:find_by_authentication_id).returns(nil).once
    service.any_instance.expects(:find_by_email).returns(OpenStruct.new(user: user)).once
    assert_equal user, service.run(user_data, auth_provider, relation).user
  end

  def test_find_by_email
    users = relation
    users.expects(:find_by).with(email: nil).once
    service.any_instance.expects(:find_by_uid).returns(OpenStruct.new(user: nil)).at_least_once
    result = service.run(ThreeScale::OAuth2::UserData.new, auth_provider, users)
    assert_nil result.user
    assert_nil result.error_message

    users.expects(:find_by).with(email: 'foo@example.org').returns(mock('user')).once
    result = service.run(ThreeScale::OAuth2::UserData.new(email: 'foo@example.org'), auth_provider, users)
    assert_nil result.user
    assert_match 'User cannot be authenticated by not verified email address', result.error_message

    users.expects(:find_by).with(email: 'foo@example.org').returns(mock('user')).once
    result = service.run(ThreeScale::OAuth2::UserData.new(email_verified: true, email: 'foo@example.org'), auth_provider, users)
    assert_not_nil result.user
    assert_nil result.error_message
  end

  def test_find_by_sso_authorization
    service.any_instance.expects(:find_by_email).returns(nil).at_least_once
    SSOAuthorization.expects(:find_by).never
    service.run(ThreeScale::OAuth2::UserData.new, {}, [])

    SSOAuthorization.expects(:find_by).once
    service.run(ThreeScale::OAuth2::UserData.new(uid: 'foo'), auth_provider, [])
  end

  def test_find_by_authentication_id
    users = relation
    users.expects(:find_by).with(authentication_id: 'foo').never
    service.any_instance.expects(:find_by_email).returns(nil).at_least_once
    service.any_instance.expects(:find_by_sso_authorization).returns(nil).at_least_once
    service.run(ThreeScale::OAuth2::UserData.new, auth_provider, users)

    users.expects(:find_by).with(authentication_id: 'foo').once
    service.run(ThreeScale::OAuth2::UserData.new(authentication_id: 'foo'), auth_provider, users)
  end

  def test_confirmed_email
    user_data = ThreeScale::OAuth2::UserData.new(email_verified: true, email: 'test@example.com')
    users = relation
    user = mock('user')
    users.expects(:find_by).with(email: 'test@example.com').returns(user)

    assert_equal user, service.run(user_data, nil, users).user
  end

  private

  def auth_provider
    mock('auth_provider')
  end

  def user_data
    ThreeScale::OAuth2::UserData.new
  end

  def relation
    UsersDouble.allocate
  end

  def service
    Users::FindOauth2UserService
  end
end
