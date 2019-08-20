require 'minitest_helper'

class ThreeScaleAnalyticsUserClassifierTest < MiniTest::Unit::TestCase

  def classifier(attributes)
    user_classifier = ThreeScale::Analytics::UserClassifier.new(User.new(attributes))
    user_classifier.stubs(:internal_email_regex).returns(/@(3scale\.net|redhat\.com)$/ix)
    user_classifier
  end


  def test_has_3scale_email?
    refute classifier(email: 'foo@example.com').has_3scale_email?

    assert classifier(email: 'foo@3scale.net').has_3scale_email?

    assert classifier(email: 'FOO@3SCALE.NET').has_3scale_email?

    assert classifier(email: 'foo@redhat.com').has_3scale_email?
    assert classifier(email: 'foo@REDHAT.COM').has_3scale_email?
  end


  def test_is_impersonation_admin?
    refute classifier(username: 'foo').is_impersonation_admin?

    assert classifier(username: ThreeScale.config.impersonation_admin['username']).is_impersonation_admin?
  end

  def test_is_3scale?
    impersonation_admin_username = ThreeScale.config.impersonation_admin['username']
    refute classifier(email: 'foo@example.com', username: 'foo').is_3scale?
    assert classifier(email: 'foo@example.com', username: impersonation_admin_username).is_3scale?
    assert classifier(email: 'foo@3scale.net',  username: impersonation_admin_username).is_3scale?
    assert classifier(email: 'foo@3scale.net',  username: 'foo').is_3scale?
  end

  def test_is_guest?
    assert classifier(email: nil, username: nil).is_guest?
    assert classifier(email: 'user@example.com', username: nil).is_guest?
    assert classifier(email: nil, username: 'user').is_guest?

    refute classifier(email: 'foo@3scale.net', username: 'foo').is_guest?
  end

  def test_user_type
    impersonation_admin_username = ThreeScale.config.impersonation_admin['username']
    assert_equal 'customer', classifier(email: 'user@example.com', username: 'user').user_type

    assert_equal '3scale', classifier(email: 'user@3scale.net', username: 'user').user_type

    assert_equal 'impersonation_admin', classifier(email: 'user@example.com', username: impersonation_admin_username).user_type
    assert_equal 'impersonation_admin', classifier(email: 'user@3scale.net',  username: impersonation_admin_username).user_type

    assert_equal 'guest', classifier(email: nil, username: nil).user_type
    assert_equal 'guest', classifier(email: 'user@example.com', username: nil).user_type
    assert_equal 'guest', classifier(email: nil, username: 'user').user_type

    assert_equal 'guest', ThreeScale::Analytics::UserClassifier.new(nil).user_type
  end
end
