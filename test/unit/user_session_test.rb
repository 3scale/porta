require 'test_helper'

class UserSessionTest < ActiveSupport::TestCase


  def request
    ActionDispatch::Request.new({})
  end

  test 'generates a key' do
    us = UserSession.new(user_id: 42)
    assert us.valid?

    assert_not_nil us.key
  end

  test 'a revoked key is not active' do
    us = UserSession.create!(user_id: 42)

    us.revoke!

    refute UserSession.active.include?(us)
  end

  test 'access without user does not persist the session' do

    us = UserSession.null

    assert_difference 'UserSession.count', 0 do
      us.access(request)
    end
  end

  test 'revoke does not create session' do

    us = UserSession.null

    assert_difference 'UserSession.count', 0 do
      us.revoke!
    end
  end

  test 'different scenarios for user agent' do
    session = UserSession.new

    session.user_agent = 'foobar'
    assert_equal 'foobar', session.user_agent

    session.user_agent = 'a' * 260
    assert_equal 'a' * 255, session.user_agent
    refute session.valid?

    session.user_agent = nil
    assert_nil session.user_agent
    refute session.valid?

    session.user_agent = 'a' * 253
    assert_equal 'a' * 253, session.user_agent
    session.save

    session.user_agent = 'a'*1000
    assert_equal 'a' * 255, session.user_agent
  end

  test 'stale' do
    session1 = UserSession.create!(user_id: 1, key: 'key1', revoked_at: 1.month.ago)
    session2 = UserSession.create!(user_id: 2, key: 'key2', accessed_at: 3.weeks.ago)
    session3 = UserSession.create!(user_id: 3, key: 'key3', accessed_at: 1.week.ago)

    stale  = UserSession.stale
    assert_includes stale, session1
    assert_includes stale, session2
    refute_includes stale, session3
  end
end
