# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::TopicsControllerTest < ActionDispatch::IntegrationTest
  include System::UrlHelpers.cms_url_helpers

  def setup
    skip('SaaS-only feature') if System::Database.oracle?

    @provider = FactoryBot.create(:provider_account)
    provider.settings.update_column(:forum_enabled, true)
    @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    FactoryBot.create(:cms_page, provider: provider, path: '/', published: true)

    login_buyer buyer
  end

  attr_reader :buyer, :provider

  test 'admin cannot create sticky topics' do
    assert_difference(admin_user.topics.method(:count)) do
      post forum_topics_path, params: { topic: {title: 'In your face!', body: 'Blah blah',	sticky: 1} }
    end

    forum_topic = admin_user.topics.order(created_at: :asc).last!
    assert_equal 'In your face!', forum_topic.title
    refute forum_topic.sticky
  end

  test 'User cannot edit his topics after the first day' do
    travel_to(1.day.ago) { forum_topic }

    put forum_topic_path(forum_topic)

    assert_response :forbidden
  end

  test 'user cannot update other user\'s topics' do
    member = FactoryBot.create(:member, account: buyer)
    forum_topic(user: member)

    put forum_topic_path(forum_topic)

    assert_response :forbidden
  end

  test 'user cannot delete other user\'s topics' do
    member = FactoryBot.create(:member, account: buyer)
    forum_topic(user: member)

    delete forum_topic_path(forum_topic)

    assert_response :forbidden
  end

  private

  def admin_user
    @admin_user ||= buyer.admin_user
  end

  def forum_topic(user: admin_user)
    @forum_topic ||= FactoryBot.create(:topic, user: user, forum: provider.create_forum)
  end
end
