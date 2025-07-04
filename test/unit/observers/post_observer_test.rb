require 'test_helper'

class PostObserverTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  def test_after_commit_on_create
    provider = FactoryBot.create(:provider_account)
    forum    = FactoryBot.create(:forum, account: provider)
    topic    = FactoryBot.create(:topic, forum: forum)
    admin    = provider.first_admin
    admin.notification_preferences.update(preferences: { post_created: true })
    user     = FactoryBot.create(:user, account: provider)

    assert_difference(Notification.where(title: "New forum post by #{user.username}").method(:count), +1) do
      with_sidekiq do
        FactoryBot.create(:post, user:, topic:)
      end
    end
  end
end
