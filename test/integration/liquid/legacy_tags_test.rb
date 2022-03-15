# frozen_string_literal: true

require 'test_helper'

class Liquid::LegacyTagsTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    login_buyer(@buyer)
  end

  test 'latest_forum_posts' do
    topic = FactoryBot.create(:topic, forum: @provider.forum)
    FactoryBot.create(:post, forum: @provider.forum, topic: topic)
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

  # Bug in production https://app.bugsnag.com/3scale-networks-sl/system/errors/622f614862800a00091a1f9b
  test 'buyer/1/analytics.js' do
    override_dashboard_with %(
      {% content_for javascripts %}
        {{ 'buyer/1/analytics' | javascript_include_tag }}
      {% endcontent_for %}
      All is good
    )

    get '/admin'
    assert_response :success
    assert_match /All is good/, response.body
  end

  private

  def override_dashboard_with(content)
    @provider.builtin_pages.create!(system_name: 'dashboards/show',
                                    published: content,
                                    section: @provider.sections.root)
  end

end
