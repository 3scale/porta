require 'test_helper'

class PostTest < ActiveSupport::TestCase
  def setup
    @user  = Factory(:simple_user)

    @forum = Factory(:forum, :account => @user.account)
    @topic = Factory(:topic, :forum => @forum, :user => @user)
  end

  def teardown
    User.current = nil
  end

  def test_latest_first
    assert_equal [Post.last], Post.latest_first.to_a
    assert_equal 1, Post.latest_first.count
  end

  test 'forum is assigned from topic' do
    post = Post.new(:body => 'Blah') do |post|
      post.user  = @user
      post.topic = @topic
      post.save!
    end

    assert_equal @forum, post.forum
  end

  test 'delegates tags to the topic' do
    User.current = @user.reload

    @topic.tag_list = 'tag1, tag2, tag3'
    @topic.save!

    post = Post.new(:body => 'Blah') do |post|
      post.user  = @user
      post.topic = @topic
      post.save!
    end

    assert_equal @topic.tags, post.tags
  end
end

# TODO: convert these to test/unit:

# describe Post do
#   describe 'tags handling' do
#   end
#
#   describe 'first_stream method' do
#     before(:each) do
#       @topic = Topic.make :tag_list => "stream1, stream2"
#       #OPTIMIZE improve this when creating streams is not so complicated as now is
#       Stream.should_receive(:find).any_number_of_times.and_return(["stream1", "stream2"])
#       @post = Post.make :topic => @topic
#     end
#
#     it 'should return the topic first stream' do
#       @post.first_stream.should == @topic.first_stream
#     end
#   end
#
#   describe "anonymous posting" do
#     before(:each) do
#       # @account = build_buyer_account_from_factories
#       @topic = Topic.make
#     end
#
#     it "should respond true when asked" do
#       post = @topic.posts.new(:body => :test, :anonymous_user => true)
#       post.user = @topic.user
#       post.forum = @topic.forum
#       post.save!
#       post.reload
#       puts post.to_yaml
#       post.anonymous_user?.should == true
#     end
#
#   end
# end
