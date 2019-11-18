require 'test_helper'

module Tasks
  class ForumTest < ActiveSupport::TestCase

    def test_migrate_forum
      admin_1, admin_2 = FactoryBot.create_list(:simple_user, 2)
      account = FactoryBot.create(:simple_account, users: [admin_2])
      forum_1 = FactoryBot.create(:forum)
      forum_2 = FactoryBot.create(:forum, account: account)

      FactoryBot.create(:post, user: admin_1, forum: forum_1,
        topic: FactoryBot.create(:topic, user: admin_1, forum: forum_1))
      FactoryBot.create(:post, user: admin_1, forum: forum_1,
        topic: FactoryBot.create(:topic, user: admin_1, forum: forum_1))

      ENV.stubs(:[])
      ENV.stubs(:[]).with('CURRENT_FORUM_ID').returns(forum_1.id)
      ENV.stubs(:[]).with('NEW_FORUM_ID').returns(forum_2.id)

      assert_equal 2, forum_1.topics.count
      assert_equal 0, forum_2.topics.count
      assert_equal 4, forum_1.posts.count
      assert_equal 0, forum_2.posts.count

      (forum_1.topics.to_a + forum_1.posts.to_a).each do |object|
        assert_equal object.user_id, admin_1.id
      end

      execute_rake_task 'forum/migrate_forum.rake', 'forum:migrate_forum'

      forum_1.reload
      forum_2.reload

      assert_equal 0, forum_1.topics.count
      assert_equal 2, forum_2.topics.count
      assert_equal 0, forum_1.posts.count
      assert_equal 4, forum_2.posts.count

      (forum_2.topics.to_a + forum_2.posts.to_a).each do |object|
        assert_equal object.user_id, admin_2.id
      end
    end
  end
end
