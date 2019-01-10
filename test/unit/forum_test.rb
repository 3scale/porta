require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  test 'topics.smart_search uses sphinx if search query given' do
    skip 'Not available for Oracle' if System::Database.oracle?

    forum = FactoryBot.create(:forum)

    search = ThinkingSphinx.search
    ThinkingSphinx::Search.expects(:new).returns(search)

    forum.topics.smart_search('foo')
  end

  test 'smart_search escapes the query' do
    skip 'Not available for Oracle' if System::Database.oracle?

    forum = FactoryBot.create(:forum)

    ThinkingSphinx::Test.run do
      assert forum.topics.smart_search('fo/o').populate
    end
  end

  test 'topics.search does not use sphinx if query is empty' do
    forum = FactoryBot.create(:forum)
    topic_one = FactoryBot.create(:topic, :forum => forum)
    topic_two = FactoryBot.create(:topic, :forum => forum)

    ThinkingSphinx::Search.expects(:new).never

    assert_same_elements [topic_one, topic_two], forum.topics.smart_search
  end

  test 'topics.search does not return topics of other forums if query is empty' do
    forum_one = FactoryBot.create(:forum)
    topic_one = FactoryBot.create(:topic, :forum => forum_one)

    forum_two = FactoryBot.create(:forum)
    topic_two = FactoryBot.create(:topic, :forum => forum_two)

    assert_does_not_contain forum_one.topics.smart_search, topic_two
  end

  test 'topics.search return paginated collection when query is empty' do
    forum  = FactoryBot.create(:forum)
    topics = forum.topics.smart_search

    assert_respond_to topics, :total_pages
  end
end
