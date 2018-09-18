require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TopicTest < ActiveSupport::TestCase
  setup do
    skip 'Not available for Oracle' if System::Database.oracle?
  end

  test 'destroy' do
    topic = FactoryGirl.create(:topic)

    assert topic.destroy
  end

  test 'delegates account and account_id to forum' do
    forum = Factory(:forum)
    topic = Factory(:topic, :forum => forum)
    assert_equal topic.account, forum.account
    assert_equal topic.account_id, forum.account_id
  end

  test 'with_post_by returns only topics with at least one post by the given user' do
    forum = Factory(:forum)
    alice = Factory(:simple_user, :account => forum.account)
    bob   = Factory(:simple_user, :account => forum.account)

    topic_one = Factory(:topic, :forum => forum)
    topic_two = Factory(:topic, :forum => forum)

    Factory(:post, :topic => topic_one, :user => alice)
    Factory(:post, :topic => topic_two, :user => bob)

    assert_same_elements [topic_one], forum.topics.with_post_by(alice)
  end

  test 'with_post_by does not return the same topic more than once' do
    forum = Factory(:forum)
    bob   = Factory(:simple_user, :account => forum.account)

    topic_one = Factory(:topic, :forum => forum)
    topic_two = Factory(:topic, :forum => forum)
    topic_three = Factory(:topic, :forum => forum)

    Factory(:post, :topic => topic_one, :user => bob)
    Factory(:post, :topic => topic_two, :user => bob)
    Factory(:post, :topic => topic_two, :user => bob)
    Factory(:post, :topic => topic_three, :user => bob)

    assert_same_elements [topic_one, topic_two, topic_three], forum.topics.with_post_by(bob)
  end

  test 'topic subscriptions get deleted along with topic' do
    forum = Factory(:forum)
    bob   = Factory(:simple_user, :account => forum.account)

    topic_one = Factory(:topic, :forum => forum)
    subscription = topic_one.user_topics.create :user => bob

    assert_not_nil Topic.find_by_id topic_one.id
    assert_not_nil UserTopic.find_by_id subscription.id

    topic_one.destroy
    assert_nil Topic.find_by_id topic_one.id
    assert_nil UserTopic.find_by_id subscription.id
  end

  test 'topic created by last user is not nil' do
    topic = FactoryGirl.create(:topic)
    post  = FactoryGirl.create(:post, topic: topic)
    topic.update_cached_post_fields(post)


    assert_equal post.created_at.to_s, topic.last_updated_at.to_s
    assert_equal post.user_id, topic.last_user_id
    assert_equal post.id, topic.last_post_id
    topic.reload

    assert_equal topic.posts.count, topic.posts_count
  end

  test 'updates cached columns on when plan is destroyed' do
    topic = FactoryGirl.create(:topic)
    previous_post = topic.posts.first!

    post  = FactoryGirl.create(:post, topic: topic, user_id: 99)

    post.destroy
    assert post.frozen?

    topic.update_cached_post_fields(post)

    assert_equal previous_post.created_at.to_s, topic.last_updated_at.to_s
    assert_equal previous_post.user_id, topic.last_user_id
    assert_equal previous_post.id, topic.last_post_id
    topic.reload

    assert_equal topic.posts.count, topic.posts_count
  end

  def test_destroy_topic_with_anonynous_post
    topic = FactoryGirl.create(:topic)
    posts = FactoryGirl.create_list(:post, 2, topic: topic)
    posts << FactoryGirl.create(:post, topic: topic, user_id: nil, anonymous_user: true)
    assert 3, topic.posts.count
    assert topic.destroy!
  end

  # TODO: Convert these to tests

  # describe 'tag_names method' do 
  #   context 'when no tags' do
  #     before(:each) do
  #       @topic = Topic.make
  #     end

  #     it 'should return []' do
  #       @topic.tag_names.should be_empty
  #     end
  #   end

  #   context 'with tags' do
  #     before(:each) do
  #       @topic = Topic.make :tag_list => "tag1, tag2, tag3"
  #     end

  #     it 'should return the array of names' do
  #       @topic.tag_names.should == %w(tag1 tag2 tag3)
  #     end
  #   end
  # end

  # describe 'with_tag class method' do
  #   before(:all) do
  #     @untagged = Topic.make
  #     @tagged = Topic.make :tag_list => "tag1"
  #   end

  #   context 'with tag param nil' do
  #     it 'should return all topics' do
  #       Topic.with_tag(nil).should == Topic.all
  #     end
  #   end

  #   context 'with tag param blank' do
  #     it 'should return all topics' do
  #       Topic.with_tag('').should == Topic.all
  #     end
  #   end

  #   context 'with tag param that no topic have' do
  #     it 'should return []' do
  #       Topic.with_tag('no-tag').should be_empty
  #     end
  #   end

  #   context 'with existent tag param' do
  #     it 'should return all tagged topics' do
  #       Topic.with_tag('tag1').should == [@tagged]
  #     end
  #   end
  # end

  # describe 'first_stream method' do
  #   context 'with no tagged stream' do
  #     it 'should return nil' do
  #       Topic.new.first_stream.should be_nil
  #     end
  #   end

  #   context 'with tagged stream' do
  #     before(:each) do
  #       @topic = Topic.make :tag_list => "stream1, stream2"
  #       #OPTIMIZE improve this when creating streams is not so complicated as now is
  #       Stream.should_receive(:find).and_return(["stream1", "stream2"])
  #     end

  #     it 'should return first stream' do
  #       @topic.first_stream.should == "stream1"
  #     end
  #   end
  # end
end
