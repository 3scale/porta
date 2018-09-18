require 'test_helper'

class Posts::PostCreatedEventTest < ActiveSupport::TestCase

  def test_create_registered_user
    forum = FactoryGirl.build_stubbed(:forum)
    post  = FactoryGirl.build_stubbed(:post, forum: forum)
    event = Posts::PostCreatedEvent.create(post)

    assert event
    assert_equal event.forum, forum
    assert_equal event.post, post
    assert_equal event.provider, forum.account
    assert_equal event.metadata[:provider_id], forum.account_id
    assert_equal event.user, post.user
    assert_equal event.account, post.user.account
  end

  def test_create_anonymous_user
    forum = FactoryGirl.build_stubbed(:forum)
    post  = FactoryGirl.build_stubbed(:post, forum: forum, user: nil)
    event = Posts::PostCreatedEvent.create(post)

    assert event
    assert_equal event.forum, forum
    assert_equal event.post, post
    assert_equal event.provider, forum.account
    assert_equal event.metadata[:provider_id], forum.account_id
    assert_equal event.try(:user), nil
    assert_equal event.try(:account), nil
  end
end
