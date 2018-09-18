require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Abilities::ForumsTest < ActiveSupport::TestCase
  def setup
    @provider = Factory(:provider_account)
    @forum = @provider.forum
  end

  def test_posts
    assert_equal [], @forum.posts.to_a
    assert_equal 0, @forum.posts.size
  end

  test 'anyone can read topic when forum is public' do
    @forum.account.settings.update_attribute(:forum_public, true)
    user  = Factory(:user, :account => @provider)
    topic = Factory(:topic, :forum => @forum)

    ability = Ability.new(user)
    assert ability.can?(:read, topic)

    ability = Ability.new(nil)
    assert ability.can?(:read, topic)
  end

  test 'just logged in users can read topic when forum is not public' do
    @forum.account.settings.update_attribute(:forum_public, false)
    provider_user  = Factory(:user, :account => @provider)
    buyer = Factory(:buyer_account, :provider_account => @provider)
    buyer_user = Factory(:user, :account => buyer)
    topic = Factory(:topic, :forum => @forum)

    ability = Ability.new(provider_user)
    assert ability.can?(:read, topic)

    ability = Ability.new(buyer_user)
    assert ability.can?(:read, topic)

    ability = Ability.new(nil)
    assert !ability.can?(:read, topic)
  end

  test "topic owner can update and destroy topic if it is less than one day old" do
    topic = Factory(:topic)
    user  = topic.user

    ability = Ability.new(user)

    assert ability.can?(:update, topic)
    assert ability.can?(:destroy, topic)
  end

  test "topic owner can't update nor destroy topic if it is more than one day old" do
    topic = Factory(:topic)
    user  = topic.user

    ability = Ability.new(user)

    Timecop.travel(2.days.from_now) do
      assert !ability.can?(:update, topic)
      assert !ability.can?(:destroy, topic)
    end
  end

  test "user can't update not destroy topic of other user" do
    user_one = Factory(:user_with_account)
    user_two = Factory(:user_with_account)
    topic = Factory(:topic, :user => user_one)

    ability = Ability.new(user_two)
    assert !ability.can?(:update, topic)
    assert !ability.can?(:destroy, topic)
  end

  test "admin can manage any topic of his forum" do
    admin = @provider.admins.first
    user  = Factory(:user, :account => @provider)

    ability = Ability.new(admin)

    topic_one = Factory(:topic, :forum => @forum, :user => admin)
    assert ability.can?(:manage, topic_one)

    topic_two = Factory(:topic, :forum => @forum, :user => user)
    assert ability.can?(:manage, topic_two)

    topic_three = Factory(:topic, :forum => @forum, :user => user)
    Timecop.travel(2.days.from_now) do
      assert ability.can?(:manage, topic_three)
    end
  end

  test "admin can stick a topic" do
    topic = Factory(:topic, :forum => @forum)

    ability = Ability.new(@provider.admins.first)
    assert ability.can?(:stick, topic)
  end

  test "user can't stick a topic" do
    topic = Factory(:topic, :forum => @forum)
    user  = Factory(:user, :account => @provider)

    ability = Ability.new(user)
    assert !ability.can?(:stick, topic)
  end

  test "post author can update and destroy post if it is less than one day old" do
    post = Factory(:post)
    user = post.user

    ability = Ability.new(user)

    assert ability.can?(:update, post)
    assert ability.can?(:destroy, post)
  end

  test "post author can't update nor destroy post if it is more than one day old" do
    post = Factory(:post)
    user = post.user

    ability = Ability.new(user)

    Timecop.travel(2.days.from_now) do
      assert !ability.can?(:update, post)
      assert !ability.can?(:destroy, post)
    end
  end

  test "user can't update not destroy post of other user" do
    user_one = Factory(:user_with_account)
    user_two = Factory(:user_with_account)
    post = Factory(:post, :user => user_one)

    ability = Ability.new(user_two)

    assert !ability.can?(:update, post)
    assert !ability.can?(:destroy, post)
  end

  test "user can't destroy a post if it is the last one in the topic" do
    topic = Factory(:topic)
    topic.posts[1..-1].each(&:destroy) # Just in case

    ability = Ability.new(topic.user)
    assert !ability.can?(:destroy, topic.posts.first)
  end

  test "admin can manage any post of his forum" do
    topic = Factory(:topic, :forum => @forum)
    admin = @provider.admins.first
    user  = Factory(:user, :account => @provider)

    ability = Ability.new(admin)

    post_one = Factory(:post, :topic => topic, :user => admin)
    assert ability.can?(:manage, post_one)

    post_two = Factory(:post, :topic => topic, :user => user)
    assert ability.can?(:manage, post_two)

    post_three = Factory(:post, :topic => topic, :user => user)
    Timecop.travel(2.days.from_now) do
      assert ability.can?(:manage, post_three)
    end
  end

  test 'anyone can read category in public forum' do
    @forum.account.settings.update_attribute(:forum_public, true)
    category = @forum.categories.create!(:name => 'Junk')

    buyer    = Factory(:buyer_account)
    buyer_user = Factory(:user, :account => buyer)
    provider_user = Factory(:user, :account => @provider)

    ability = Ability.new(buyer_user)
    assert ability.can?(:read, category)

    ability = Ability.new(provider_user)
    assert ability.can?(:read, category)

    ability = Ability.new(nil)
    assert ability.can?(:read, category)
  end

  test 'buyer user can read category in private forum' do
    @forum.account.settings.update_attribute(:forum_public, false)

    account = Factory(:buyer_account, :provider_account => @provider)
    user = Factory(:user, :account => account)
    category = @forum.categories.create!(:name => 'Junk')

    ability = Ability.new(user)
    assert ability.can?(:read, category)
  end

  test 'provider user can read category in private forum' do
    @forum.account.settings.update_attribute(:forum_public, false)

    user = Factory(:user, :account => @provider)
    category = @forum.categories.create!(:name => 'Junk')

    ability = Ability.new(user)
    assert ability.can?(:read, category)
  end

  test "user can't manage category" do
    category = @forum.categories.create!(:name => 'Stuff')
    user = Factory(:user, :account => @provider)

    ability = Ability.new(user)

    assert !ability.can?(:create,  TopicCategory)
    assert !ability.can?(:update,  category)
    assert !ability.can?(:destroy, category)
  end

  test "buyer admin can't manage category" do
    category = @forum.categories.create!(:name => 'Stuff')
    buyer = Factory(:buyer_account, :provider_account => @provider)

    ability = Ability.new(buyer.admins.first)

    assert !ability.can?(:create,  TopicCategory)
    assert !ability.can?(:update,  category)
    assert !ability.can?(:destroy, category)
  end

  test "admin can manage category of his forum" do
    category = @forum.categories.create!(:name => 'Stuff')

    ability = Ability.new(@provider.admins.first)

    assert ability.can?(:create,  TopicCategory)
    assert ability.can?(:update,  category)
    assert ability.can?(:destroy, category)
  end

  test "user can create anonymous post if anonymous posting is enabled" do
    @forum.account.settings.update_attribute(:anonymous_posts_enabled, true)
    user  = Factory(:user, :account => @provider)
    topic = Factory(:topic, :forum => @forum)
    post  = topic.posts.build

    # logged in user
    ability = Ability.new(user)
    assert ability.can?(:reply, topic)
    assert ability.can?(:reply, post)

    # anon user
    ability = Ability.new(nil)
    assert ability.can?(:reply, topic)
    assert ability.can?(:reply, post)
  end

  test "user can't create anonymous post if anonymous posting is disabled" do
    @forum.account.settings.update_attribute(:anonymous_posts_enabled, false)
    user  = Factory(:user, :account => @provider)
    topic = Factory(:topic, :forum => @forum)
    post  = topic.posts.build

    # logged in users
    ability = Ability.new(user)
    assert ability.can?(:reply, topic)
    assert ability.can?(:reply, post)

    # anon users
    ability = Ability.new(nil)
    assert !ability.can?(:reply, topic)
    assert !ability.can?(:reply, post)
  end


  context "Topic with category" do
    should "can reply" do
      @forum.account.settings.update_attribute(:anonymous_posts_enabled, false)

      category = Factory(:topic_category, :forum => @forum)
      topic = category.topics.build

      user  = Factory(:user, :account => @provider)
      # logged in provider
      ability = Ability.new(user)
      assert ability.can?(:reply, topic)

      buyer = Factory(:buyer_account, :provider_account => @provider)
      buyer_user = Factory(:user, :account => buyer)
      # logged in buyer
      ability = Ability.new(user)
      assert ability.can?(:reply, topic)

      # anon user
      ability = Ability.new(nil)
      assert !ability.can?(:reply, topic)

      @forum.account.settings.update_attribute(:anonymous_posts_enabled, true)
      topic = category.reload.topics.build
      assert ability.can?(:reply, topic)
    end

    should "be manageable by admin" do
      category = Factory(:topic_category, :forum => @forum)
      admin    = Factory(:admin, :account => @provider)

      ability = Ability.new(admin)
      assert ability.can?(:manage, category.topics.build)
      assert ability.can?(:manage, @forum.topics.build)
    end
  end
end
