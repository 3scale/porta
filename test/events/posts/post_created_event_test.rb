require 'test_helper'

class Posts::PostCreatedEventTest < ActiveSupport::TestCase

  def test_create_registered_user
    forum = FactoryBot.build_stubbed(:forum)
    post  = FactoryBot.build_stubbed(:post, forum: forum)
    event = Posts::PostCreatedEvent.create(post)

    assert event
    assert_equal forum, event.forum
    assert_equal post, event.post
    assert_equal forum.account, event.provider
    assert_equal forum.account_id, event.metadata[:provider_id]
    assert_equal post.user, event.user
    assert_equal post.user.account, event.account
  end

  def test_create_anonymous_user
    forum = FactoryBot.build_stubbed(:forum)
    post  = FactoryBot.build_stubbed(:post, forum: forum, user: nil)
    event = Posts::PostCreatedEvent.create(post)

    assert event
    assert_equal forum, event.forum
    assert_equal post, event.post
    assert_equal forum.account, event.provider
    assert_equal forum.account_id, event.metadata[:provider_id]
    assert_nil event.try(:user)
    assert_nil event.try(:account)
  end
end
