# frozen_string_literal: true

require 'test_helper'

class ThreeScale::OAuth2::UserDataTest < ActiveSupport::TestCase

  test '.build' do
    user_data = ThreeScale::OAuth2::UserData.build(client)
    assert user_data
  end

  test '.new' do
    user_data = ThreeScale::OAuth2::UserData.new(attributes)

    assert_equal 'foo@example.com', user_data.email
    assert_equal 'foo', user_data.username
    assert_equal 'bar|123', user_data.uid
    assert_equal 'org', user_data.org_name
    assert_equal 'auth0', user_data.kind
    assert_equal 'alaska', user_data.authentication_id
    assert_equal 'IdTokenTest', user_data.id_token
  end

  test '#==' do
    expected_data = ThreeScale::OAuth2::UserData.new(attributes)

    assert_equal expected_data, attributes
  end

  test '#to_hash' do
    user_data = ThreeScale::OAuth2::UserData.new(attributes)

    assert_equal({ email: 'foo@example.com', username: 'foo' }, user_data.to_hash)
  end

  test '#to_h' do
    user_data = ThreeScale::OAuth2::UserData.new(attributes)

    assert_equal attributes, user_data.to_h
  end

  test '#[]' do
    user_data = ThreeScale::OAuth2::UserData.new(attributes)

    assert_equal 'foo', user_data[:username]
    assert_equal 'foo@example.com', user_data[:email]
  end

  def test_email_verified?
    user_data = ThreeScale::OAuth2::UserData.new(email: 'foo@example.com')
    refute user_data.email_verified?

    user_data = ThreeScale::OAuth2::UserData.new(email: 'foo@example.com', email_verified: true)
    assert user_data.email_verified?

    user_data = ThreeScale::OAuth2::UserData.new(email_verified: true)
    refute user_data.email_verified?
  end

  def test_verified_email
    user_data = ThreeScale::OAuth2::UserData.new(email: 'foo@example.com')
    refute user_data.verified_email

    user_data = ThreeScale::OAuth2::UserData.new(email: 'foo@example.com', email_verified: true)
    assert_equal 'foo@example.com', user_data.email
  end

  protected

  def attributes
    { email: 'foo@example.com', email_verified: true, username: 'foo', uid: 'bar|123', org_name: 'org', kind: 'auth0',
      authentication_id: 'alaska', id_token: 'IdTokenTest' }
  end

  def client
    client = ThreeScale::OAuth2::ClientBase.new(authentication)
    client.stubs(access_token: stub('access-token', params: {'id_token' => 'openid id token'}))
    client
  end

  def authentication
    stub('Authentication', client_id: 'id', client_secret: 'secret', options: {}, identifier_key: 'uid')
  end
end
