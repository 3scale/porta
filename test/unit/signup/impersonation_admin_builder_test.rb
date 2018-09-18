# frozen_string_literal: true

require 'test_helper'

class Signup::ImpersonationAdminBuilderTest < ActiveSupport::TestCase
  test '#build & save should create a ThreeScaleAdminUser' do
    user_returned = Signup::ImpersonationAdminBuilder.build(account: account)
    user_returned.save!
    config = ThreeScale.config.impersonation_admin
    username  = config['username']
    user_db = User.find_by!(username: username)
    assert_equal user_returned, user_db
    assert_equal "#{username}+#{account.self_domain}@#{config['domain']}", user_db.email
    assert_equal '3scale', user_db.first_name
    assert_equal 'Admin', user_db.last_name
    assert_equal 'active', user_db.state
    assert_equal :admin, user_db.role
    assert_equal :minimal, user_db.signup_type
  end

  private

  def account
    @account ||= Factory.build(:account)
  end
end
