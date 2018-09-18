require 'test_helper'

class Liquid::LegacyTagsTest < ActionDispatch::IntegrationTest
  def setup
    @provider = Factory(:provider_account)
    @buyer = Factory(:buyer_account, provider_account: @provider)
    login_buyer(@buyer)
  end

  test 'latest_forum_posts' do
    topic = Factory(:topic, forum: @provider.forum)
    Factory(:post, forum: @provider.forum, topic: topic)
    override_dashboard_with '{% latest_forum_posts %}'

    get '/admin'

    assert_response :success
    assert_match /Latest.Forum.Activity/, response.body
  end

  test 'latest_messages' do
    override_dashboard_with '{% latest_messages %}'

    get '/admin'

    assert_response :success
    assert_match /No new messages/, response.body
  end

  private

  def override_dashboard_with(content)
    @provider.builtin_pages.create!(system_name: 'dashboards/show',
                                    published: content,
                                    section: @provider.sections.root)
  end

end
