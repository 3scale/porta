require 'test_helper'

class Forums::Public::TopicsTest < ActionDispatch::IntegrationTest

  def setup
    provider = FactoryBot.create(:provider_account)
    @forum   = FactoryBot.create(:forum, account: provider)
    @topic   = FactoryBot.create(:topic, forum: @forum, user: provider.admins.first!)

    provider.settings.forum_enabled = true
    provider.settings.forum_public  = true

    host! provider.domain
  end

  def test_request_formats
    get forum_topic_path(id: @topic.permalink, format: :zip)
    assert_response :not_acceptable

    get forum_topic_path(id: @topic.permalink)
    assert_response :success

    get forum_topic_path(id: @topic.permalink, format: :html)
    assert_response :success
  end
end
