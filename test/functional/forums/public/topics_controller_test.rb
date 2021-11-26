# frozen_string_literal: true

require 'test_helper'

class Forums::Public::TopicsControllerTest < ActionController::TestCase
  setup do
    @provider = FactoryBot.create(:provider_account)
    @request.host = @provider.domain

    @forum = FactoryBot.create(:forum, account: @provider)
    @topic = FactoryBot.create(:topic, forum: @forum, user: @provider.admins.first!)

    @provider.settings.forum_enabled = true
    @provider.settings.forum_public = true
  end

  class RegardlessOfAnonymousPostingTest < Forums::Public::TopicsControllerTest
    test "create topic missing title" do
      login_as @provider.admins.first

      post :create, params: { topic: { body: 'No idea why I wrote that.' } }
      assert_response :success
    end

    test "create topic" do
      login_as @provider.admins.first

      post :create, params: { topic: { title: 'The king has returned!',  body: 'No idea why I wrote that.' } }
      assert_response :redirect
    end

    test "update topic missing title" do
      login_as @provider.admins.first

      put :update, params: { id: @topic.permalink, topic: { title: '', body: 'new thing' } }
      assert_response :success
    end

    test "update topic" do
      login_as @provider.admins.first

      put :update, params: { id: @topic.permalink, topic: { title: 'HOT STUFF', body: 'new thing' } }
      assert_response :redirect
    end

    test 'list posts within topic ascendingly: oldest on the top' do
      @topic.posts.delete_all
      post1 = FactoryBot.create(:post, topic: @topic, user_id: 99, created_at: 10.days.ago)
      post2 = FactoryBot.create(:post, topic: @topic, user_id: 88, created_at: 1.day.ago)

      get :show, params: { id: @topic.permalink }

      posts = assigns(:posts)

      assert_equal [post1, post2], posts.to_a
      assert_equal posts.first, post1
      assert_equal posts.last,  post2
    end
  end

  class AnonymousPostingTest < Forums::Public::TopicsControllerTest
    class EnabledTest < AnonymousPostingTest
      def setup
        super
        @provider.settings.anonymous_posts_enabled = true
        @provider.settings.save!
      end

      test "should anonymous have a hidden field" do
        get :show, params: { id: @topic.permalink }
        assert_match @topic.body, @response.body
        assert_select 'input#post_anonymous_user[type=hidden]'
      end

      test "should provider has a field" do
        login_as @provider.admins.first

        get :show, params: { id: @topic.permalink }

        assert_match @topic.body, @response.body
        assert_select 'input#post_anonymous_user'
      end

      test "should buyer has a field" do
        buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
        login_as buyer.admins.first

        get :show, params: { id: @topic.permalink }
        assert_match @topic.body, @response.body

        assert_select 'input#post_anonymous_user'
      end
    end

    class DisabledTest < AnonymousPostingTest
      def setup
        super
        @provider.settings.anonymous_posts_enabled = false
        @provider.settings.save!
      end

      test "should not have fields for anonymous" do
        get :show, params: { id: @topic.permalink }

        assert_match @topic.body, @response.body
        assert_select 'input#post_anonymous_user', count: 0
      end

      test "should not have fields when logged in as a provider" do
        login_as @provider.admins.first

        get :show, params: { id: @topic.permalink }

        assert_match @topic.body, @response.body
        assert_select 'input#post_anonymous_user', count: 0
      end

      test "should have no field when logged in as a buyer" do
        buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
        login_as buyer.admins.first

        get :show, params: { id: @topic.permalink }

        assert_match @topic.body, @response.body
        assert_select 'input#post_anonymous_user', count: 0
      end
    end
  end
end
