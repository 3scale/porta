require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Forums::Public::TopicsControllerTest < ActionController::TestCase
  setup do
    @provider = Factory :provider_account
    @request.host = @provider.domain

    @forum = Factory :forum, :account => @provider
    @topic = Factory :topic, :forum => @forum, :user => @provider.admins.first!

    @provider.settings.forum_enabled = true
    @provider.settings.forum_public  = true
  end


  context "TopicsController" do
    should "create topic" do
      login_as @provider.admins.first

      # missing title
      post :create, topic: { body: 'No idea why I wrote that.' }
      assert_response :success

      post :create, topic: { title: 'The king has returned!',  body: 'No idea why I wrote that.' }
      assert_response :redirect
    end

    should "update topic" do
      login_as @provider.admins.first

      # empty title
      put :update, :id => @topic.permalink, topic: { title: '', body: 'new thing' }
      assert_response :success

      put :update, :id => @topic.permalink, topic: { title: 'HOT STUFF', body: 'new thing' }
      assert_response :redirect
    end

    context "anonymous posting enabled" do
      setup do
        @provider.settings.anonymous_posts_enabled = true
        @provider.settings.save!
      end

      should "anonymous have a hidden field" do
        get :show, :id => @topic.permalink
        assert_match @topic.body, @response.body
        assert_select 'input#post_anonymous_user[type=hidden]'
      end


      should "provider has a field" do
        login_as @provider.admins.first

        get :show, :id => @topic.permalink

        assert_match @topic.body, @response.body
        assert_select 'input#post_anonymous_user'
      end


      should "buyer has a field" do
        buyer = Factory :buyer_account, :provider_account => @provider
        login_as buyer.admins.first

        get :show, :id => @topic.permalink
        assert_match @topic.body, @response.body

        assert_select 'input#post_anonymous_user'
      end
    end # enabled

    context "anonymous posting when disabled" do
      setup do
        @provider.settings.anonymous_posts_enabled = false
        @provider.settings.save!
      end

      should "not have fields for anonymous" do
        get :show, :id => @topic.permalink

        assert_match @topic.body, @response.body
        assert_select 'input#post_anonymous_user', count: 0
      end


      should "not have fields when logged in as a provider" do
        login_as @provider.admins.first

        get :show, :id => @topic.permalink

        assert_match @topic.body, @response.body
        assert_select 'input#post_anonymous_user', count: 0
      end

      should "have no field when logged in as a buyer" do
        buyer = Factory :buyer_account, :provider_account => @provider
        login_as buyer.admins.first

        get :show, :id => @topic.permalink

        assert_match @topic.body, @response.body
        assert_select 'input#post_anonymous_user', count: 0
      end
    end # disabled
  end

  test 'list posts within topic ascendingly: oldest on the top' do
    @topic.posts.delete_all
    post1  = FactoryBot.create(:post, topic: @topic, user_id: 99, created_at: 10.days.ago)
    post2  = FactoryBot.create(:post, topic: @topic, user_id: 88, created_at: 1.day.ago)

    get :show, :id => @topic.permalink

    posts = assigns(:posts)

    assert_equal [post1, post2], posts.to_a
    assert_equal posts.first, post1
    assert_equal posts.last,  post2
  end

end
