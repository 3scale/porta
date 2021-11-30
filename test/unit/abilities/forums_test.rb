# frozen_string_literal: true

require 'test_helper'

module Abilities
  class ForumsTest < ActiveSupport::TestCase
    def setup
      @provider = FactoryBot.create(:provider_account)
      @admin_user = @provider.admins.first
      # admin = FactoryBot.create(:admin, account: @provider)
      @provider_user = FactoryBot.create(:user, account: @provider)

      @forum = @provider.forum
      @topic = FactoryBot.create(:topic, forum: @forum)

      @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
      @buyer_user = FactoryBot.create(:user, account: @buyer)
    end

    def test_posts
      forum = FactoryBot.create(:provider_account).forum
      assert_equal [], forum.posts.to_a
      assert_equal 0, forum.posts.size
    end

    test 'anyone can read topic when forum is public' do
      @forum.account.settings.update(forum_public: true)

      assert Ability.new(@provider_user).can?(:read, @topic)
      assert Ability.new(nil).can?(:read, @topic)
    end

    test 'just logged in users can read topic when forum is not public' do
      @forum.account.settings.update(forum_public: false)

      assert Ability.new(@provider_user).can?(:read, @topic)
      assert Ability.new(@buyer_user).can?(:read, @topic)
      assert_not Ability.new(nil).can?(:read, @topic)
    end

    test "topic owner can update and destroy topic if it is less than one day old" do
      owner = Ability.new(@topic.user)

      assert owner.can?(:update, @topic)
      assert owner.can?(:destroy, @topic)
    end

    test "topic owner can't update nor destroy topic if it is more than one day old" do
      owner = Ability.new(@topic.user)

      Timecop.travel(2.days.from_now) do
        assert_not owner.can?(:update, @topic)
        assert_not owner.can?(:destroy, @topic)
      end
    end

    test "user can't update not destroy topic of other user" do
      another_user_topic = FactoryBot.create(:topic, user: FactoryBot.create(:user_with_account))

      user = Ability.new(FactoryBot.create(:user_with_account))
      assert_not user.can?(:update, another_user_topic)
      assert_not user.can?(:destroy, another_user_topic)
    end

    test "admin can manage any topic of his forum" do
      admin = Ability.new(@admin_user)

      topic_one = FactoryBot.create(:topic, forum: @forum, user: @admin_user)
      assert admin.can?(:manage, topic_one)

      topic_two = FactoryBot.create(:topic, forum: @forum, user: @provider_user)
      assert admin.can?(:manage, topic_two)

      topic_three = FactoryBot.create(:topic, forum: @forum, user: @provider_user)
      Timecop.travel(2.days.from_now) do
        assert admin.can?(:manage, topic_three)
      end
    end

    test "admin can stick a topic" do
      assert Ability.new(@admin_user).can?(:stick, @topic)
    end

    test "user can't stick a topic" do
      assert_not Ability.new(@provider_user).can?(:stick, @topic)
    end

    test "post author can update and destroy post if it is less than one day old" do
      post = FactoryBot.create(:post)

      post_author = Ability.new(post.user)

      assert post_author.can?(:update, post)
      assert post_author.can?(:destroy, post)
    end

    test "post author can't update nor destroy post if it is more than one day old" do
      post = FactoryBot.create(:post)

      post_author = Ability.new(post.user)

      Timecop.travel(2.days.from_now) do
        assert_not post_author.can?(:update, post)
        assert_not post_author.can?(:destroy, post)
      end
    end

    test "user can't update not destroy post of other user" do
      another_user_post = FactoryBot.create(:post, user: FactoryBot.create(:user_with_account))

      user = Ability.new(FactoryBot.create(:user_with_account))
      assert_not user.can?(:update, another_user_post)
      assert_not user.can?(:destroy, another_user_post)
    end

    test "user can't destroy a post if it is the last one in the topic" do
      topic = FactoryBot.create(:topic)
      assert_equal 1, topic.posts.length

      owner = topic.user
      ability = Ability.new(owner)
      assert_not ability.can?(:destroy, topic.posts.first)

      FactoryBot.create(:post, topic: topic, user: owner)
      assert_equal 2, topic.reload.posts.length
      assert ability.can?(:destroy, topic.posts.first)
    end

    test "admin can manage any post of his forum" do
      admin = Ability.new(@admin_user)

      post_one = FactoryBot.create(:post, topic: @topic, user: @admin_user)
      assert admin.can?(:manage, post_one)

      post_two = FactoryBot.create(:post, topic: @topic, user: @provider_user)
      assert admin.can?(:manage, post_two)

      post_three = FactoryBot.create(:post, topic: @topic, user: @provider_user)
      Timecop.travel(2.days.from_now) do
        assert admin.can?(:manage, post_three)
      end
    end

    test 'anyone can read category in public forum' do
      @forum.account.settings.update(forum_public: true)
      category = @forum.categories.create!(name: 'Junk')

      assert Ability.new(@buyer_user).can?(:read, category)
      assert Ability.new(@provider_user).can?(:read, category)
      assert Ability.new(nil).can?(:read, category)
    end

    test 'buyer and provider user can read category in private forum' do
      @forum.account.settings.update(forum_public: false)
      category = @forum.categories.create!(name: 'Junk')

      assert Ability.new(@buyer_user).can?(:read, category)
      assert Ability.new(@provider_user).can?(:read, category)
    end

    test "user can't manage category" do
      category = @forum.categories.create!(name: 'Stuff')

      user = Ability.new(@provider_user)
      assert_not user.can?(:create, TopicCategory)
      assert_not user.can?(:update, category)
      assert_not user.can?(:destroy, category)
    end

    test "buyer admin can't manage category" do
      category = @forum.categories.create!(name: 'Stuff')

      admin = Ability.new(@buyer.admins.first)
      assert_not admin.can?(:create, TopicCategory)
      assert_not admin.can?(:update, category)
      assert_not admin.can?(:destroy, category)
    end

    test "admin can manage category of his forum" do
      category = @forum.categories.create!(name: 'Stuff')

      ability = Ability.new(@admin_user)

      assert ability.can?(:create, TopicCategory)
      assert ability.can?(:update, category)
      assert ability.can?(:destroy, category)
    end

    test "user can create anonymous post if anonymous posting is enabled" do
      @forum.account.settings.update(anonymous_posts_enabled: true)
      post = @topic.posts.build

      logged_in_user = Ability.new(@provider_user)
      assert logged_in_user.can?(:reply, @topic)
      assert logged_in_user.can?(:reply, post)

      anonymous_user = Ability.new(nil)
      assert anonymous_user.can?(:reply, @topic)
      assert anonymous_user.can?(:reply, post)
    end

    test "user can't create anonymous post if anonymous posting is disabled" do
      @forum.account.settings.update(anonymous_posts_enabled: false)
      post = @topic.posts.build

      logged_in_user = Ability.new(@provider_user)
      assert logged_in_user.can?(:reply, @topic)
      assert logged_in_user.can?(:reply, post)

      anonymous_user = Ability.new(nil)
      assert_not anonymous_user.can?(:reply, @topic)
      assert_not anonymous_user.can?(:reply, post)
    end

    test "Topic with category should can reply" do
      @forum.account.settings.update(anonymous_posts_enabled: false)
      category = FactoryBot.create(:topic_category, forum: @forum)
      topic = category.topics.build

      assert Ability.new(@provider_user).can?(:reply, topic)
      assert Ability.new(@buyer_user).can?(:reply, topic)

      anonymous_user = Ability.new(nil)
      assert_not anonymous_user.can?(:reply, topic)

      @forum.account.settings.update(anonymous_posts_enabled: true)
      topic = category.reload.topics.build
      assert anonymous_user.can?(:reply, topic)
    end

    test "Topic with category should be manageable by admin" do
      category = FactoryBot.create(:topic_category, forum: @forum)

      admin = Ability.new(@admin_user)
      assert admin.can?(:manage, category.topics.build)
      assert admin.can?(:manage, @forum.topics.build)
    end
  end
end
