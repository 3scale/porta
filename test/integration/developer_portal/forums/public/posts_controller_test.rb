# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::PostsControllerTest < ActionDispatch::IntegrationTest
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

  test 'user cannot edit his posts after the first day' do
    travel_to(1.day.ago) { forum_post }

    put forum_post_path(forum_post)

    assert_response :forbidden
  end

  test 'user cannot update other user\'s posts' do
    member = FactoryBot.create(:member, account: buyer)
    forum_post(user: member)

    put forum_post_path(forum_post)

    assert_response :forbidden
  end

  test 'user cannot delete other user\'s posts' do
    member = FactoryBot.create(:member, account: buyer)
    forum_post(user: member)

    delete forum_post_path(forum_post)

    assert_response :forbidden
  end

  private

  def forum_post(user: buyer.admin_user)
    @forum_post ||= begin
      post = FactoryBot.create(:post, user: user)
      provider.forum.posts << post
      post
    end
  end
end
