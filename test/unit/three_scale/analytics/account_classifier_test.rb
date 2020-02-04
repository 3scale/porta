require 'minitest_helper'

class ThreeScale::Analytics::AccountClassifierTest < MiniTest::Unit::TestCase


  def classifier(user_attributes = {})
    provider = FactoryBot.build_stubbed(:provider_account)
    provider.stubs(:users).returns([
                                       FactoryBot.build_stubbed(:admin,
                                                                 username: ThreeScale.config.impersonation_admin['username']),
                                       FactoryBot.build_stubbed(:admin, user_attributes)
                                   ])

    ThreeScale::Analytics::AccountClassifier.new(provider)
  end

  def test_is_3scale?
    ThreeScale::Analytics::UserClassifier.any_instance.stubs(:internal_email_regex).returns(/@(example\.com)$/i)
    refute classifier(email: 'user@example.net').is_3scale?
    assert classifier(email: 'user@example.com').is_3scale?
    refute classifier.is_3scale?
  end

  def test_account_type
    assert_equal 'Customer', classifier(email: 'user@example.net', username: 'user').account_type

    impersonation_admin_config = ThreeScale.config.impersonation_admin
    impersonation_admin_username = impersonation_admin_config['username']
    assert_equal 'Internal', classifier(email: 'user@example.net', username: impersonation_admin_username).account_type
    assert_equal 'Customer', classifier(email: "user@#{impersonation_admin_config['domain']}", username: 'user').account_type
    assert_equal 'Internal', classifier(email: "user@#{impersonation_admin_config['domain']}", username: impersonation_admin_username).account_type

    assert_equal 'Customer', classifier(email: nil, username: nil).account_type
    assert_equal 'Customer', classifier(email: 'user@example.com', username: nil).account_type
    assert_equal 'Customer', classifier(email: nil, username: 'user').account_type

    assert_equal 'Internal', ThreeScale::Analytics::AccountClassifier.new(nil).account_type
  end
end
